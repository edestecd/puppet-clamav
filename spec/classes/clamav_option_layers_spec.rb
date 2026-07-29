require 'spec_helper'

supported_os = on_supported_os
ubuntu_2004_facts = supported_os.fetch('ubuntu-20.04-x86_64')
ubuntu_2404_facts = Marshal.load(Marshal.dump(ubuntu_2004_facts))
ubuntu_2404_facts[:operatingsystemrelease] = '24.04'
ubuntu_2404_facts[:operatingsystemmajrelease] = '24.04'
ubuntu_2404_facts[:os]['release']['full'] = '24.04'
ubuntu_2404_facts[:os]['release']['major'] = '24.04'
redhat_8_facts = supported_os.fetch('redhat-8-x86_64')

describe 'clamav', type: :class do
  context 'on Ubuntu 24.04 with the characterized production inputs' do
    let(:facts) { ubuntu_2404_facts }
    let(:params) do
      {
        user: 'root',
        group: 'root',
        manage_clamd: true,
        manage_freshclam: true,
        manage_repo: false,
        clamd_use_socket: false,
        clamd_options: {
          'LogClean' => 'yes',
          'LogFile' => '/var/log/clamav/clamav.log',
          'LogSyslog' => 'yes',
          'LogVerbose' => 'yes',
          'MaxScanSize' => '4095M',
          'MaxFileSize' => '4095M',
        },
        freshclam_options: {
          'LogTime' => 'yes',
          'NotifyClamd' => '/etc/clamav/clamd.conf',
          'PrivateMirror' => ['https://steamvault.galois.com/clamav'],
          'UpdateLogFile' => '/var/log/clamav/freshclam.log',
        },
      }
    end

    it { is_expected.to compile.with_all_deps }

    it 'layers caller clamd options over the Ubuntu production defaults' do
      is_expected.to contain_file('clamd.conf')
        .with(owner: 'root', group: 'root', mode: '0644')
        .with_content(%r{^CommandReadTimeout 30$}m)
        .with_content(%r{^LocalSocket /var/run/clamav/clamd\.ctl$}m)
        .with_content(%r{^LogClean yes$}m)
        .with_content(%r{^LogSyslog yes$}m)
        .with_content(%r{^MaxRecursion 16$}m)
        .with_content(%r{^MaxScanTime 120000$}m)
        .with_content(%r{^MaxFileSize 4095M$}m)
        .with_content(%r{^MaxScanSize 4095M$}m)
        .with_content(%r{^PCREMatchLimit 10000$}m)
        .with_content(%r{^PCREMaxFileSize 25M$}m)
        .with_content(%r{^PCRERecMatchLimit 5000$}m)
    end

    it 'layers caller freshclam options over the Ubuntu production defaults' do
      is_expected.to contain_file('freshclam.conf')
        .with(owner: 'root', group: 'root', mode: '0644')
        .with_content(%r{^Bytecode true$}m)
        .with_content(%r{^ReceiveTimeout 0$}m)
        .with_content(%r{^LogTime yes$}m)
        .with_content(%r{^NotifyClamd /etc/clamav/clamd\.conf$}m)
        .with_content(%r{^PrivateMirror https://steamvault\.galois\.com/clamav$}m)
    end

    it 'retains direct clamd service management' do
      is_expected.to contain_service('clamd')
        .with_name('clamav-daemon')
        .with_ensure('running')
        .with_enable(true)
      is_expected.not_to contain_service('clamd_socket')
    end

    it 'does not create clamonacc operational resources' do
      is_expected.not_to contain_package('clamonacc')
      is_expected.not_to contain_file('clamonacc.conf')
      is_expected.not_to contain_service('clamonacc')
    end
  end

  context 'on Ubuntu 24.04 with caller scanner limit overrides' do
    let(:facts) { ubuntu_2404_facts }
    let(:params) do
      {
        manage_clamd: true,
        clamd_options: {
          'CommandReadTimeout' => 45,
          'MaxScanTime' => 180_000,
          'MaxRecursion' => 20,
          'PCREMatchLimit' => 20_000,
          'PCRERecMatchLimit' => 6000,
          'PCREMaxFileSize' => '30M',
        },
      }
    end

    it 'applies caller options after the Ubuntu production defaults' do
      is_expected.to contain_file('clamd.conf')
        .with_content(%r{^CommandReadTimeout 45$}m)
        .with_content(%r{^MaxRecursion 20$}m)
        .with_content(%r{^MaxScanTime 180000$}m)
        .with_content(%r{^PCREMatchLimit 20000$}m)
        .with_content(%r{^PCREMaxFileSize 30M$}m)
        .with_content(%r{^PCRERecMatchLimit 6000$}m)
    end
  end

  context 'on Ubuntu 20.04 without release-specific data' do
    let(:facts) { ubuntu_2004_facts }
    let(:params) { { manage_clamd: true, manage_freshclam: true } }

    it { is_expected.to compile.with_all_deps }

    it 'combines generic clamd defaults with Debian platform data' do
      is_expected.to contain_file('clamd.conf')
        .with_content(%r{^Bytecode true$}m)
        .with_content(%r{^LocalSocket /var/run/clamav/clamd\.ctl$}m)
        .with_content(%r{^LocalSocketGroup clamav$}m)
        .with_content(%r{^LogFile /var/log/clamav/clamav\.log$}m)
        .with_content(%r{^PidFile /var/run/clamav/clamd\.pid$}m)
        .with_content(%r{^TemporaryDirectory /tmp$}m)
        .with_content(%r{^User clamav$}m)
    end

    it 'combines generic freshclam defaults with Debian platform data' do
      is_expected.to contain_file('freshclam.conf')
        .with_content(%r{^Bytecode true$}m)
        .with_content(%r{^DatabaseOwner clamav$}m)
        .with_content(%r{^PidFile /var/run/clamav/freshclam\.pid$}m)
        .with_content(%r{^UpdateLogFile /var/log/clamav/freshclam\.log$}m)
    end
  end

  context 'on RedHat 8 without release-specific data' do
    let(:facts) { redhat_8_facts }
    let(:params) do
      {
        manage_repo: false,
        manage_clamd: true,
        manage_freshclam: true,
      }
    end

    it { is_expected.to compile.with_all_deps }

    it 'combines generic clamd defaults with RedHat platform data' do
      is_expected.to contain_file('clamd.conf')
        .with_content(%r{^Bytecode true$}m)
        .with_content(%r{^LocalSocket /var/run/clamd\.scan/clamd\.sock$}m)
        .with_content(%r{^LocalSocketGroup clamscan$}m)
        .with_content(%r{^LogSyslog true$}m)
        .with_content(%r{^PidFile /var/run/clamd\.scan/clamd\.pid$}m)
        .with_content(%r{^TemporaryDirectory /var/tmp$}m)
        .with_content(%r{^User clamscan$}m)
        .without_content(%r{^LogFile\s}m)
        .without_content(%r{^LogRotate\s}m)
    end

    it 'combines generic freshclam defaults with RedHat platform data' do
      is_expected.to contain_file('freshclam.conf')
        .with_content(%r{^DatabaseOwner clamupdate$}m)
        .with_content(%r{^LogSyslog true$}m)
        .without_content(%r{^PidFile\s}m)
        .without_content(%r{^UpdateLogFile\s}m)
    end
  end
end

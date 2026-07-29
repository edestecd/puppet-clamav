require 'spec_helper'

# These examples characterize public behavior inherited from the 3.0.0
# baseline. They intentionally describe compatibility contracts rather than a
# preferred future implementation.
# rubocop:disable RSpec/MultipleDescribes

supported_os = on_supported_os
debian_11_facts = supported_os.fetch('debian-11-x86_64')
redhat_7_facts = supported_os.fetch('redhat-7-x86_64')
redhat_8_facts = supported_os.fetch('redhat-8-x86_64')

describe 'clamav', type: :class do
  context 'on Debian 11' do
    let(:facts) { debian_11_facts }

    context 'with clamd replacement defaults and caller overrides' do
      let(:params) do
        {
          manage_clamd: true,
          clamd_default_options: {
            'MaxThreads' => 20,
            'ReplacementDefault' => 'present',
          },
          clamd_options: {
            'MaxThreads' => 30,
            'CallerOption' => 'present',
          },
        }
      end

      it { is_expected.to compile.with_all_deps }

      it 'replaces module defaults and applies caller options last' do
        is_expected.to contain_file('clamd.conf')
          .with_path('/etc/clamav/clamd.conf')
          .with_content(%r{^MaxThreads 30$}m)
          .with_content(%r{^ReplacementDefault present$}m)
          .with_content(%r{^CallerOption present$}m)
          .without_content(%r{^Bytecode\s}m)
          .without_content(%r{^LocalSocket\s}m)
      end
    end

    context 'with freshclam replacement defaults and caller overrides' do
      let(:params) do
        {
          manage_freshclam: true,
          freshclam_default_options: {
            'Checks' => 12,
            'ReplacementDefault' => 'present',
          },
          freshclam_options: {
            'Checks' => 6,
            'CallerOption' => 'present',
          },
        }
      end

      it 'replaces module defaults and applies caller options last' do
        is_expected.to contain_file('freshclam.conf')
          .with_path('/etc/clamav/freshclam.conf')
          .with_content(%r{^Checks 6$}m)
          .with_content(%r{^ReplacementDefault present$}m)
          .with_content(%r{^CallerOption present$}m)
          .without_content(%r{^DatabaseMirror\s}m)
      end
    end

    context 'with account management explicitly suppressed' do
      let(:params) do
        {
          manage_user: true,
          user: false,
          group: false,
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.not_to contain_user('clamav') }
      it { is_expected.not_to contain_group('clamav') }
    end

    context 'with clamd and freshclam managed' do
      let(:params) { { manage_clamd: true, manage_freshclam: true } }

      it do
        is_expected.to contain_package('clamd')
          .with_name('clamav-daemon')
          .that_comes_before('File[clamd.conf]')
      end

      it do
        is_expected.to contain_service('clamd')
          .with_name('clamav-daemon')
          .with_ensure('running')
          .with_enable(true)
          .that_subscribes_to('Package[clamd]')
          .that_subscribes_to('File[clamd.conf]')
      end

      it do
        is_expected.to contain_package('freshclam')
          .with_name('clamav-freshclam')
          .that_comes_before('File[freshclam.conf]')
      end

      it do
        is_expected.to contain_service('freshclam')
          .with_name('clamav-freshclam')
          .with_ensure('running')
          .with_enable(true)
      end
    end
  end

  context 'on RedHat 7' do
    let(:facts) { redhat_7_facts }
    let(:pre_condition) { 'class epel {}' }
    let(:params) { { manage_clamd: true, manage_freshclam: true } }

    it { is_expected.to contain_class('epel') }
    it { is_expected.to contain_package('clamd').with_name('clamav-scanner-systemd') }
    it { is_expected.to contain_package('freshclam').with_name('clamav-update') }
    it { is_expected.not_to contain_service('freshclam') }
  end

  context 'on RedHat 8' do
    let(:facts) { redhat_8_facts }
    let(:params) do
      {
        manage_repo: false,
        manage_freshclam: true,
        freshclam_delay: 'disabled',
      }
    end

    it { is_expected.to compile.with_all_deps }

    it do
      is_expected.to contain_file('freshclam_sysconfig')
        .with_path('/etc/sysconfig/freshclam')
        .with_content(%r{^FRESHCLAM_DELAY=disabled$}m)
    end

    it do
      is_expected.to contain_service('freshclam')
        .with_name('clamav-freshclam')
        .with_ensure('running')
        .with_enable(true)
    end
  end

  context 'with milter replacement defaults on RedHat 8' do
    let(:facts) { redhat_8_facts }
    let(:params) do
      {
        manage_repo: false,
        manage_clamav_milter: true,
        milter_default_options: {
          'User' => 'replacement-user',
          'ReplacementDefault' => 'present',
        },
        clamav_milter_options: {
          'User' => 'caller-user',
          'CallerOption' => 'present',
        },
      }
    end

    it 'replaces module defaults and applies caller options last' do
      is_expected.to contain_file('clamav-milter.conf')
        .with_content(%r{^User caller-user$}m)
        .with_content(%r{^ReplacementDefault present$}m)
        .with_content(%r{^CallerOption present$}m)
        .without_content(%r{^MilterSocket\s}m)
    end
  end
end

describe 'clamav::clamd', type: :class do
  let(:facts) { debian_11_facts }
  let(:pre_condition) { 'include clamav' }
  let(:params) { { sort_options: false } }

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_package('clamd').with_name('clamav-daemon') }
  it { is_expected.to contain_file('clamd.conf').with_path('/etc/clamav/clamd.conf') }
  it { is_expected.to contain_service('clamd').with_name('clamav-daemon') }
end

describe 'clamav::freshclam', type: :class do
  let(:facts) { debian_11_facts }
  let(:pre_condition) { 'include clamav' }
  let(:params) do
    {
      config_owner: 'freshclam-owner',
      config_group: 'freshclam-group',
      config_mode: '0440',
      sort_options: false,
    }
  end

  it { is_expected.to compile.with_all_deps }

  it do
    is_expected.to contain_file('freshclam.conf').with(
      path: '/etc/clamav/freshclam.conf',
      owner: 'freshclam-owner',
      group: 'freshclam-group',
      mode: '0440',
    )
  end
end

describe 'clamav::clamav_milter', type: :class do
  let(:facts) { redhat_8_facts }
  let(:pre_condition) { 'class epel {}; include clamav' }
  let(:params) { { sort_options: false } }

  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_package('clamav_milter').with_name('clamav-milter-systemd') }
  it { is_expected.to contain_file('clamav-milter.conf').with_path('/etc/mail/clamav-milter.conf') }
  it { is_expected.to contain_service('clamav_milter').with_name('clamav-milter') }
end

# rubocop:enable RSpec/MultipleDescribes

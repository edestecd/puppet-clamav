require 'spec_helper'

supported_os = on_supported_os
redhat_7_facts = supported_os.fetch('redhat-7-x86_64')
redhat_8_facts = supported_os.fetch('redhat-8-x86_64')
redhat_9_facts = Marshal.load(Marshal.dump(redhat_8_facts))
redhat_9_facts[:operatingsystemrelease] = '9.0'
redhat_9_facts[:operatingsystemmajrelease] = '9'
redhat_9_facts[:os]['release']['full'] = '9.0'
redhat_9_facts[:os]['release']['major'] = '9'

describe 'clamav', type: :class do
  context 'with the real puppet/epel fixture' do
    {
      'RedHat 7.9' => redhat_7_facts,
      'RedHat 9' => redhat_9_facts,
    }.each do |label, os_facts|
      context "on #{label}" do
        let(:facts) { os_facts }
        let(:params) { { manage_clamd: true } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('epel') }

        it 'manages the matching EPEL repository and signing key' do
          major = os_facts[:operatingsystemmajrelease]

          is_expected.to contain_yumrepo('epel').with(
            gpgkey: "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-#{major}",
          )
          is_expected.to contain_file("/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-#{major}")
        end

        it do
          is_expected.to contain_package('clamd')
            .with_name('clamav-scanner-systemd')
        end
      end
    end
  end
end

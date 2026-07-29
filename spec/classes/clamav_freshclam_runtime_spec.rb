require 'spec_helper'

supported_os = on_supported_os
ubuntu_2004_facts = supported_os.fetch('ubuntu-20.04-x86_64')
ubuntu_2204_facts = supported_os.fetch('ubuntu-22.04-x86_64')

describe 'clamav', type: :class do
  context 'on Ubuntu 20.04 with freshclam managed' do
    let(:facts) { ubuntu_2004_facts }
    let(:params) { { manage_freshclam: true } }

    it { is_expected.to compile.with_all_deps }

    it do
      is_expected.to contain_file('/var/run/clamav')
        .with_ensure('directory')
        .with_owner('clamav')
        .with_group('clamav')
        .with_mode('0755')
        .that_requires('Package[freshclam]')
        .that_comes_before('File[freshclam.conf]')
    end
  end

  context 'on Ubuntu 20.04 with account names overridden' do
    let(:facts) { ubuntu_2004_facts }
    let(:params) do
      {
        manage_freshclam: true,
        user: 'clam-scanner',
        group: 'clam-scanner',
      }
    end

    it do
      is_expected.to contain_file('/var/run/clamav').with(
        owner: 'clam-scanner',
        group: 'clam-scanner',
      )
    end
  end

  context 'on another Ubuntu release' do
    let(:facts) { ubuntu_2204_facts }
    let(:params) { { manage_freshclam: true } }

    it { is_expected.not_to contain_file('/var/run/clamav') }
  end
end

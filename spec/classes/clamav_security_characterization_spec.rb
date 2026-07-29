require 'spec_helper'

describe 'clamav' do
  supported_os = on_supported_os

  context 'on Debian 11' do
    let(:facts) { supported_os.fetch('debian-11-x86_64') }

    context 'with clamd and freshclam managed' do
      let(:params) do
        {
          manage_clamd: true,
          manage_freshclam: true,
        }
      end

      it do
        is_expected.to contain_file('clamd.conf').with(
          owner: 'root',
          group: 'root',
          mode: '0644',
        )
      end

      it do
        is_expected.to contain_file('freshclam.conf').with(
          owner: 'clamav',
          group: 'adm',
          mode: '0444',
        )
      end

      it do
        is_expected.to contain_file('clamd.conf')
          .with_content(%r{^LocalSocketMode 666$}m)
      end
    end

    context 'with a group-restricted socket mode override' do
      let(:params) do
        {
          manage_clamd: true,
          clamd_options: {
            'LocalSocketMode' => '660',
          },
        }
      end

      it do
        is_expected.to contain_file('clamd.conf')
          .with_content(%r{^LocalSocketMode 660$}m)
          .without_content(%r{^LocalSocketMode 666$}m)
      end
    end

    context 'with socket activation enabled' do
      let(:params) do
        {
          manage_clamd: true,
          clamd_use_socket: true,
        }
      end

      it do
        is_expected.to contain_service('clamd_socket')
          .that_requires('Package[clamd]')
          .that_requires('File[clamd.conf]')
          .without_subscribe
      end

      it do
        is_expected.to contain_file('clamd.conf').without_notify
      end

      it do
        is_expected.to contain_service('clamd')
          .with_ensure('stopped')
          .that_subscribes_to('File[clamd.conf]')
      end
    end
  end

  context 'on RedHat 8' do
    let(:facts) { supported_os.fetch('redhat-8-x86_64') }
    let(:params) do
      {
        manage_clamd: true,
        manage_repo: false,
      }
    end

    it do
      is_expected.to contain_file('clamd.conf')
        .with_content(%r{^LocalSocketMode 666$}m)
    end
  end
end

require 'spec_helper'

describe 'clamav' do
  context 'on Debian 11' do
    let(:facts) do
      {
        os: {
          family: 'Debian',
          name: 'Debian',
          release: {
            full: '11.0',
            major: '11',
          },
        },
      }
    end

    context 'with the default direct-service policy' do
      let(:params) { { manage_clamd: true } }

      it { is_expected.not_to contain_service('clamd_socket') }

      it do
        is_expected.to contain_service('clamd').with(
          ensure: 'running',
          name: 'clamav-daemon',
          enable: true,
          subscribe: ['Package[clamd]', 'File[clamd.conf]'],
        )
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
        is_expected.to contain_service('clamd_socket').with(
          ensure: 'running',
          name: 'clamav-daemon.socket',
          enable: true,
          require: ['Package[clamd]', 'File[clamd.conf]'],
        )
      end

      it do
        is_expected.to contain_service('clamd').with(
          ensure: 'stopped',
          name: 'clamav-daemon',
          enable: false,
          subscribe: ['Package[clamd]', 'File[clamd.conf]'],
        )
      end
    end

    context 'with a custom socket unit' do
      let(:params) do
        {
          manage_clamd: true,
          clamd_use_socket: true,
          clamd_socket: 'custom-clamd.socket',
        }
      end

      it { is_expected.to contain_service('clamd_socket').with_name('custom-clamd.socket') }
    end
  end

  context 'on RedHat 8' do
    let(:facts) do
      {
        os: {
          family: 'RedHat',
          name: 'RedHat',
          release: {
            full: '8.0',
            major: '8',
          },
        },
      }
    end

    context 'with the default direct-service policy' do
      let(:params) do
        {
          manage_clamd: true,
          manage_repo: false,
        }
      end

      it { is_expected.not_to contain_service('clamd_socket') }
      it { is_expected.to contain_service('clamd').with_name('clamd@scan') }
    end

    context 'when socket activation has no socket unit' do
      let(:params) do
        {
          manage_clamd: true,
          manage_repo: false,
          clamd_use_socket: true,
        }
      end

      it { is_expected.to compile.and_raise_error(%r{clamav::clamd_use_socket requires clamav::clamd_socket}) }
    end
  end
end

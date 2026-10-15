require 'spec_helper'

describe 'clamav', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with defaults' do
        it { is_expected.to compile.with_all_deps }
        if facts[:osfamily] == 'RedHat'
          it { is_expected.to contain_class('epel') }
        elsif facts[:osfamily] == 'Debian'
          it { is_expected.not_to contain_class('epel') }
        end
        it { is_expected.not_to contain_class('clamav::user') }
        it { is_expected.to contain_class('clamav::install') }
        it { is_expected.not_to contain_class('clamav::clamd') }
        it { is_expected.not_to contain_class('clamav::freshclam') }
      end

      context 'manage user' do
        let(:params) { { manage_user: true } }

        it { is_expected.to contain_class('clamav::user') }
      end

      context 'disable epel on RedHat' do
        let(:params) { { manage_repo: false } }

        it { is_expected.not_to contain_class('epel') }
      end

      context 'manage clamd and freshclam' do
        let(:params) { { manage_clamd: true, manage_freshclam: true } }

        it { is_expected.to contain_class('clamav::clamd') }
        it { is_expected.to contain_class('clamav::freshclam') }
      end

      context 'manage manage_clamav_milter' do
        if facts[:osfamily] == 'RedHat' && facts[:operatingsystemrelease] >= '7.0'
          let(:params) { { manage_clamav_milter: true } }

          it { is_expected.to contain_class('clamav::clamav_milter') }
        end
      end

      context 'clamav::user' do
        let(:params) { { manage_user: true } }

        context 'with defaults' do
          it { is_expected.to contain_group('clamav') }
          it { is_expected.to contain_user('clamav') }
        end
        context 'disable group and user' do
          let(:params) do
            {
              manage_user: true,
              group: '',
              user: '',
            }
          end

          it { is_expected.not_to contain_group('clamav') }
          it { is_expected.not_to contain_user('clamav') }
        end
      end

      context 'clamav::install' do
        context 'with defaults' do
          it { is_expected.to contain_package('clamav') }
        end
      end

      context 'clamav::clamd' do
        let(:params) { { manage_clamd: true } }

        context 'with defaults' do
          it { is_expected.to contain_package('clamd') }
          it { is_expected.to contain_file('clamd.conf') }
          it { is_expected.to contain_service('clamd') }
        end
      end

      context 'clamav::freshclam' do
        let(:params) { { manage_freshclam: true } }

        context 'with defaults' do
          if facts[:osfamily] == 'RedHat'
            if facts[:operatingsystemmajrelease].to_i == 6
              it 'is valid when there is no freshclam package' do
                is_expected.not_to contain_package('freshclam')
              end
              it 'is valid when there no file freshclam_sysconfig' do
                is_expected.not_to contain_file('freshclam_sysconfig')
              end
            elsif facts[:operatingsystemmajrelease].to_i == 7
              it 'is valid when there is freshclam package' do
                is_expected.to contain_package('freshclam')
              end
              it 'is valid when there is freshclam_sysconfig file' do
                is_expected.to contain_file('freshclam_sysconfig')
              end
            end
            it 'is valid when there is freshclam.conf file' do
              is_expected.to contain_file('freshclam.conf')
            end
            it 'is valid when there is no freshclam service' do
              is_expected.not_to contain_service('freshclam')
            end
          elsif facts[:osfamily] == 'Debian'
            it { is_expected.to contain_package('freshclam') }
            it { is_expected.to contain_file('freshclam.conf') }
            it { is_expected.to contain_service('freshclam') }
            it { is_expected.not_to contain_file('freshclam_sysconfig') }
          end
        end
      end

      context 'freshclam with all optional resources configured' do
        let(:params) do
          {
            manage_freshclam: true,
            freshclam_package: 'clamav-freshclam',
            freshclam_version: 'latest',
            freshclam_config: '/etc/clamav/freshclam.conf',
            freshclam_service: 'freshclam',
            freshclam_service_ensure: 'running',
            freshclam_service_enable: true,
            freshclam_sysconfig: '/etc/sysconfig/freshclam',
            freshclam_delay: '60',
            freshclam_options: {
              DatabaseDirectory: '/var/lib/clamav',
              Checks: '24',
            },
          }
        end

        it 'declares the FreshClam package' do
          is_expected.to contain_package('freshclam').with(
            ensure: 'latest',
            name: 'clamav-freshclam',
          )
        end

        it 'declares the FreshClam configuration file' do
          is_expected.to contain_file('freshclam.conf').with(
            ensure: 'file',
            path: '/etc/clamav/freshclam.conf',
          )
        end

        it 'renders FreshClam configuration options' do
          is_expected.to contain_file('freshclam.conf').with_content(
            %r{DatabaseDirectory /var/lib/clamav},
          )
          is_expected.to contain_file('freshclam.conf').with_content(
            %r{Checks 24},
          )
        end

        it 'declares the FreshClam sysconfig file' do
          is_expected.to contain_file('freshclam_sysconfig').with(
            ensure: 'file',
            path: '/etc/sysconfig/freshclam',
            owner: 'root',
            group: 'root',
            mode: '0644',
          )
        end

        it 'declares the FreshClam service' do
          is_expected.to contain_service('freshclam').with(
            ensure: 'running',
            name: 'freshclam',
            enable: true,
            hasrestart: true,
            hasstatus: true,
          )
        end

        it 'orders the package before the configuration file' do
          is_expected.to contain_package('freshclam').that_comes_before(
            'File[freshclam.conf]',
          )
        end
      end
    end
  end
end

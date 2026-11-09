require 'spec_helper'

describe 'clamav', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      os_family = facts[:os]['family']
      os_major = facts[:os]['release']['major'].to_i

      context 'with defaults' do
        it { is_expected.to compile.with_all_deps }
        if os_family == 'RedHat'
          it { is_expected.to contain_class('epel') }
        elsif os_family == 'Debian'
          it { is_expected.not_to contain_class('epel') }
        end
        it { is_expected.not_to contain_class('clamav::user') }
        it { is_expected.to contain_class('clamav::install') }
        it { is_expected.not_to contain_class('clamav::clamd') }
        it { is_expected.not_to contain_class('clamav::freshclam') }
        it { is_expected.not_to contain_class('clamav::clamav_milter') }
      end

      context 'manage user' do
        let(:params) { { manage_user: true } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('clamav::user') }
      end

      context 'disable epel on RedHat' do
        let(:params) { { manage_repo: false } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_class('epel') }
      end

      context 'manage clamd and freshclam' do
        let(:params) { { manage_clamd: true, manage_freshclam: true } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('clamav::clamd') }
        it { is_expected.to contain_class('clamav::freshclam') }
      end

      if os_family == 'RedHat'
        context 'manage clamav_milter' do
          let(:params) { { manage_clamav_milter: true } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('clamav::clamav_milter') }
          it { is_expected.to contain_file('clamav-milter.conf').with_path('/etc/mail/clamav-milter.conf') }
          it { is_expected.to contain_service('clamav_milter').with_name('clamav-milter') }
          it {
            is_expected.to contain_file('clamav-milter.conf').with_content(
              %r{^MilterSocket inet:8890@localhost$},
            )
          }

          if os_major >= 9
            it { is_expected.to contain_package('clamav_milter').with_name('clamav-milter') }
          else
            it { is_expected.to contain_package('clamav_milter').with_name('clamav-milter-systemd') }
          end
        end
      end

      context 'clamav::user' do
        let(:params) { { manage_user: true } }

        context 'with defaults' do
          it { is_expected.to contain_group('clamav') }
          it { is_expected.to contain_user('clamav') }
          if os_family == 'RedHat'
            it { is_expected.to contain_group('clamav').with_name('clamscan') }
            it { is_expected.to contain_user('clamav').with_name('clamscan') }
          else
            it { is_expected.to contain_group('clamav').with_name('clamav') }
            it { is_expected.to contain_user('clamav').with_name('clamav') }
          end
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
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_package('clamd') }
          it { is_expected.to contain_file('clamd.conf') }
          it { is_expected.to contain_service('clamd') }

          if os_family == 'RedHat'
            it { is_expected.to contain_file('clamd.conf').with_path('/etc/clamd.d/scan.conf') }
            it { is_expected.to contain_service('clamd').with_name('clamd@scan') }
            it { is_expected.to contain_file('clamd.conf').with_content(%r{^LocalSocket /var/run/clamd.scan/clamd.sock$}) }
            it { is_expected.to contain_file('clamd.conf').with_content(%r{^User clamscan$}) }

            if os_major >= 9
              it { is_expected.to contain_package('clamd').with_name('clamd') }
            else
              it { is_expected.to contain_package('clamd').with_name('clamav-scanner-systemd') }
            end
          elsif os_family == 'Debian'
            it { is_expected.to contain_package('clamd').with_name('clamav-daemon') }
            it { is_expected.to contain_file('clamd.conf').with_path('/etc/clamav/clamd.conf') }
            it { is_expected.to contain_service('clamd').with_name('clamav-daemon') }
            it { is_expected.to contain_file('clamd.conf').with_content(%r{^LocalSocket /var/run/clamav/clamd.ctl$}) }
          end
        end
      end

      context 'clamav::freshclam' do
        let(:params) { { manage_freshclam: true } }

        context 'with defaults' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('freshclam.conf') }
          it { is_expected.to contain_service('freshclam').with_name('clamav-freshclam') }

          if os_family == 'RedHat'
            it { is_expected.to contain_package('freshclam').with_name('clamav-update') }
            it { is_expected.to contain_file('freshclam.conf').with_path('/etc/freshclam.conf') }
            it { is_expected.to contain_file('freshclam_sysconfig').with_path('/etc/sysconfig/freshclam') }
            it { is_expected.to contain_file('freshclam.conf').with_content(%r{^DatabaseOwner clamupdate$}) }
          elsif os_family == 'Debian'
            it { is_expected.to contain_package('freshclam').with_name('clamav-freshclam') }
            it { is_expected.to contain_file('freshclam.conf').with_path('/etc/clamav/freshclam.conf') }
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

        it { is_expected.to compile.with_all_deps }

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

        it 'renders the FreshClam delay in the sysconfig file' do
          is_expected.to contain_file('freshclam_sysconfig').with_content(
            %r{^FRESHCLAM_DELAY=60$},
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

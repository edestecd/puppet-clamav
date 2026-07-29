require 'spec_helper'

describe 'clamav', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) { 'class epel {}' if facts[:osfamily] == 'RedHat' }

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

      context 'manage clamav_milter' do
        if facts[:osfamily] == 'RedHat' && facts[:operatingsystemrelease] >= '7.0'
          let(:params) { { manage_clamav_milter: true } }

          it { is_expected.to contain_class('clamav::clamav_milter') }
          it { is_expected.to contain_package('clamav_milter').with_name('clamav-milter-systemd') }
          it { is_expected.to contain_file('clamav-milter.conf').with_path('/etc/mail/clamav-milter.conf') }
          it { is_expected.to contain_service('clamav_milter').with_name('clamav-milter') }
        end
      end

      context 'clamav::user' do
        let(:params) { { manage_user: true } }

        context 'with defaults' do
          if facts[:osfamily] == 'RedHat'
            it { is_expected.to contain_group('clamav').with(name: 'clamscan', gid: 496) }

            it do
              is_expected.to contain_user('clamav').with(
                name: 'clamscan',
                uid: 496,
                gid: 496,
                home: '/',
                shell: '/sbin/nologin',
              )
            end
          else
            it { is_expected.to contain_group('clamav').with(name: 'clamav', gid: 496) }

            it do
              is_expected.to contain_user('clamav').with(
                name: 'clamav',
                uid: 496,
                gid: 496,
                home: '/var/lib/clamav',
                shell: '/bin/false',
              )
            end
          end
        end

        context 'disable group and user' do
          let(:params) { { manage_user: true, group: false, user: false } }

          it { is_expected.not_to contain_group('clamav') }
          it { is_expected.not_to contain_user('clamav') }
        end
      end

      context 'clamav::install' do
        context 'with defaults' do
          it { is_expected.to contain_package('clamav').with(name: 'clamav', ensure: 'latest') }
        end
      end

      context 'clamav::clamd' do
        let(:params) { { manage_clamd: true } }

        context 'with defaults' do
          if facts[:osfamily] == 'RedHat'
            it do
              is_expected.to contain_package('clamd')
                .with(name: 'clamav-scanner-systemd', ensure: 'latest')
                .that_comes_before('File[clamd.conf]')
            end

            it do
              is_expected.to contain_file('clamd.conf').with(
                path: '/etc/clamd.d/scan.conf',
                owner: 'root',
                group: 'root',
                mode: '0644',
              )
            end

            it do
              is_expected.to contain_service('clamd')
                .with(name: 'clamd@scan', ensure: 'running', enable: true)
                .that_subscribes_to('Package[clamd]')
                .that_subscribes_to('File[clamd.conf]')
            end
          else
            it do
              is_expected.to contain_package('clamd')
                .with(name: 'clamav-daemon', ensure: 'latest')
                .that_comes_before('File[clamd.conf]')
            end

            it do
              is_expected.to contain_file('clamd.conf').with(
                path: '/etc/clamav/clamd.conf',
                owner: 'root',
                group: 'root',
                mode: '0644',
              )
            end

            it do
              is_expected.to contain_service('clamd')
                .with(name: 'clamav-daemon', ensure: 'running', enable: true)
                .that_subscribes_to('Package[clamd]')
                .that_subscribes_to('File[clamd.conf]')
            end
          end
        end
      end

      context 'clamav::freshclam' do
        let(:params) { { manage_freshclam: true } }

        context 'with defaults' do
          if facts[:osfamily] == 'RedHat'
            it do
              is_expected.to contain_package('freshclam')
                .with(name: 'clamav-update', ensure: 'latest')
                .that_comes_before('File[freshclam.conf]')
            end

            it do
              is_expected.to contain_file('freshclam_sysconfig').with(
                path: '/etc/sysconfig/freshclam',
                owner: 'root',
                group: 'root',
                mode: '0644',
              )
            end

            it do
              is_expected.to contain_file('freshclam.conf').with(
                path: '/etc/freshclam.conf',
                owner: 'root',
                group: 'root',
                mode: '0644',
              )
            end

            if facts[:operatingsystemmajrelease].to_i >= 8
              it do
                is_expected.to contain_service('freshclam')
                  .with(name: 'clamav-freshclam', ensure: 'running', enable: true)
                  .that_subscribes_to('File[freshclam.conf]')
                  .that_subscribes_to('File[freshclam_sysconfig]')
              end

              it { is_expected.to contain_package('freshclam').that_notifies('Service[freshclam]') }
            else
              it { is_expected.not_to contain_service('freshclam') }
            end
          else
            it do
              is_expected.to contain_package('freshclam')
                .with(name: 'clamav-freshclam', ensure: 'latest')
                .that_comes_before('File[freshclam.conf]')
                .that_notifies('Service[freshclam]')
            end

            it do
              config_permissions = if facts[:operatingsystem] == 'Debian' &&
                                      facts[:operatingsystemmajrelease] == '11'
                                     {
                                       owner: 'clamav',
                                       group: 'adm',
                                       mode: '0444',
                                     }
                                   else
                                     {
                                       owner: 'root',
                                       group: 'root',
                                       mode: '0644',
                                     }
                                   end

              is_expected.to contain_file('freshclam.conf').with(
                {
                  path: '/etc/clamav/freshclam.conf',
                }.merge(config_permissions),
              )
            end

            it do
              is_expected.to contain_service('freshclam')
                .with(name: 'clamav-freshclam', ensure: 'running', enable: true)
                .that_subscribes_to('File[freshclam.conf]')
            end

            it { is_expected.not_to contain_file('freshclam_sysconfig') }
          end
        end
      end
    end
  end
end

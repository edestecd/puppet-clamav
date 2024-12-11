require 'spec_helper'

describe 'clamav', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(environment: 'test')
      end

      context 'with defaults' do
        it { is_expected.to compile.with_all_deps }
        if facts[:os]['family'] == 'RedHat'
          it { is_expected.to contain_class('epel') }
        elsif facts[:os]['family'] == 'Debian'
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
        if facts[:os]['family'] == 'RedHat' && facts[:os]['release']['full'] >= '7.0'
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
          let(:params) { { manage_user: true, group: false, user: false } }

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
          if facts[:os]['family'] == 'RedHat'
            if facts[:os]['release']['major'].to_i == 6
              it 'is valid when there is no freshclam package' do
                is_expected.not_to contain_package('freshclam')
              end
              it 'is valid when there no file freshclam_sysconfig' do
                is_expected.not_to contain_file('freshclam_sysconfig')
              end
            elsif facts[:os]['release']['major'].to_i == 7
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
          elsif facts[:os]['family'] == 'Debian'
            it { is_expected.to contain_package('freshclam') }
            it { is_expected.to contain_file('freshclam.conf') }
            it { is_expected.to contain_service('freshclam') }
            it { is_expected.not_to contain_file('freshclam_sysconfig') }
          end
        end
      end
    end
  end
end

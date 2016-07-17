require 'spec_helper'

describe 'clamav', :type => :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(:environment => 'test')
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
        let(:params) { { :manage_user => true } }
        it { is_expected.to contain_class('clamav::user') }
      end

      context 'disable epel on RedHat' do
        let(:params) { { :manage_repo => false } }
        it { is_expected.not_to contain_class('epel') }
      end

      context 'manage clamd and freshclam' do
        let(:params) { { :manage_clamd => true, :manage_freshclam => true } }
        it { is_expected.to contain_class('clamav::clamd') }
        it { is_expected.to contain_class('clamav::freshclam') }
      end

      context 'clamav::user' do
        let(:params) { { :manage_user => true } }
        context 'with defaults' do
          it { is_expected.to contain_group('clamav') }
          it { is_expected.to contain_user('clamav') }
        end
        context 'disable group and user' do
          let(:params) { { :manage_user => true, :group => false, :user => false } }
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
        let(:params) { { :manage_clamd => true } }
        context 'with defaults' do
          it { is_expected.to contain_package('clamd') }
          it { is_expected.to contain_file('clamd.conf') }
          it { is_expected.to contain_service('clamd') }
        end
      end

      context 'clamav::freshclam' do
        let(:params) { { :manage_freshclam => true } }
        context 'with defaults' do
          if facts[:osfamily] == 'RedHat'
            if facts[:operatingsystemmajrelease].to_i == 6
              it { is_expected.not_to contain_package('freshclam') }
              it { is_expected.not_to contain_file('freshclam_sysconfig') }
            elsif facts[:operatingsystemmajrelease].to_i == 7
              it { is_expected.to contain_package('freshclam') }
              it { is_expected.to contain_file('freshclam_sysconfig') }
            end
            it { is_expected.to contain_file('freshclam.conf') }
            it { is_expected.not_to contain_service('freshclam') }
          elsif facts[:osfamily] == 'Debian'
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

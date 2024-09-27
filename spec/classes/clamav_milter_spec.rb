require 'spec_helper'

describe 'clamav_milter', :type => :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(:environment => 'test')
      end

      context 'with defaults' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_class('clamav::clamav_milter') }
      end

      context 'manage clamav_milter' do
        let(:params) { { :manage_clamav_milter => true } }
        it { is_expected.to contain_class('clamav::clamav_milter') }
        context 'with defaults' do
          it { is_expected.to contain_file('clamav-milter.conf') }
          it { is_expected.to contain_service('clamav-milter') }
        end
      end
    end
  end
end

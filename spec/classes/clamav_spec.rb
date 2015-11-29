require 'spec_helper'

describe 'clamav', :type => :class do
  let(:pre_condition) { 'class epel {}' }
  let(:facts) { { :osfamily => 'RedHat', :operatingsystemrelease => '7.1' } }

  context 'default' do
    context 'RedHat' do
      it { should contain_class('epel') }
    end

    context 'Ubuntu' do
      let(:facts) { { :osfamily => 'Debian', :operatingsystem => 'Ubuntu', :operatingsystemrelease => '12.0' } }
      it { should_not contain_class('epel') }
    end

    it { should_not contain_class('clamav::user') }
    it { should contain_class('clamav::install') }
    it { should_not contain_class('clamav::clamd') }
    it { should_not contain_class('clamav::freshclam') }
  end

  context 'manage user' do
    let(:params) { { :manage_user => true } }
    it { should contain_class('clamav::user') }
  end

  context 'disable epel on RedHat' do
    let(:params) { { :manage_repo => false } }
    it { should_not contain_class('epel') }
  end

  context 'manage clamd and freshclam' do
    let(:params) { { :manage_clamd => true, :manage_freshclam => true } }
    it { should contain_class('clamav::clamd') }
    it { should contain_class('clamav::freshclam') }
  end
end

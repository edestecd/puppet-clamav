require 'spec_helper'

describe 'clamav::freshclam', :type => :class do
  let(:facts) { { :osfamily => 'Debian' } }

  context 'default' do
    context 'RedHat' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :freshclam_options => {} } }
      it { should_not contain_package('freshclam') }
      it { should_not contain_service('freshclam') }
    end

    context 'Ubuntu' do
      let(:params) do
        {
          :freshclam_package => 'clamav-freshclam',
          :freshclam_config  => '/etc/clamav/freshclam.conf',
          :freshclam_service => 'clamav-freshclam',
          :freshclam_options => {}
        }
      end

      it { should contain_package('freshclam') }
      it { should contain_file('freshclam.conf') }
      it { should contain_service('freshclam') }
    end
  end
end

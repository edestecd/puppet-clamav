require 'spec_helper'

describe 'clamav::clamd', :type => :class do
  let(:facts) { { :osfamily => 'RedHat' } }
  let(:params) { {
    :clamd_package => 'clamav',
    :clamd_config  => '/etc/clamd.conf',
    :clamd_service => 'clamav',
    :clamd_options => {},
  }}

  it { should contain_package('clamd') }
  it { should contain_file('clamd.conf') }
  it { should contain_service('clamd') }

end


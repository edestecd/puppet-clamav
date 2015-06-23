require 'spec_helper'

describe 'clamav::user', :type => :class do
  let(:params) { {
    :user  => 'clamav',
    :uid   => 496,
    :gid   => 496,
    :home  => '/var/lib/clamav',
    :shell => '/sbin/nologin',
    :group => 'clamav',
  } }

  it { should contain_group('clamav') }
  it { should contain_user('clamav') }

end

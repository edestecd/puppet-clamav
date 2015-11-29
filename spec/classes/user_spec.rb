require 'spec_helper'

describe 'clamav::user', :type => :class do
  let(:params) do
    {
      :user  => 'clamav',
      :uid   => 496,
      :gid   => 496,
      :home  => '/var/lib/clamav',
      :shell => '/sbin/nologin',
      :group => 'clamav'
    }
  end

  it { should contain_group('clamav') }
  it { should contain_user('clamav') }
end

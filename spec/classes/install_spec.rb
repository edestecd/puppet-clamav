require 'spec_helper'

describe 'clamav::install', :type => :class do
  it { should create_package('clamav') }
end

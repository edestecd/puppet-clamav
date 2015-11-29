require 'spec_helper_acceptance'

describe 'clamav' do
  context 'install' do
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'clamav':
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe package('clamav') do
      it { should be_installed }
    end
  end # install

  context 'clamd' do
    # set params
    if fact('osfamily') == 'RedHat'
      service_name = 'clamd'
      clamd_name = 'clamd'
    end

    if fact('osfamily') == 'Debian'
      service_name = 'clamav-daemon'
      clamd_name = 'clamav-daemon'
    end

    # test stuff
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'clamav':
        manage_clamd => true,
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe package(clamd_name) do
      it { should be_installed }
    end

    describe service(service_name) do
      it { should be_running }
    end
  end
end

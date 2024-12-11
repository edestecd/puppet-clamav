require 'spec_helper_acceptance'

describe 'clamav' do
  context 'install' do
    it 'works idempotently with no errors' do
      pp = <<-EOS
      class { 'clamav':
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes:  true)
    end

    describe package('clamav') do
      it { is_expected.to be_installed }
    end
  end # install

  context 'clamd' do
    # set params
    if fact('os.family') == 'RedHat'
      service_name = 'clamd'
      clamd_name = 'clamd'
    end

    if fact('os.family') == 'Debian'
      service_name = 'clamav-daemon'
      clamd_name = 'clamav-daemon'
    end

    # test stuff
    it 'is_expected.to work idempotently with no errors' do
      pp = <<-EOS
      class { 'clamav':
        manage_clamd => true,
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package(clamd_name) do
      it { is_expected.to be_installed }
    end

    describe service(service_name) do
      it { is_expected.to be_running }
    end
  end
end

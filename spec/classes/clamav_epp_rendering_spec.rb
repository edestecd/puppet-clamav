require 'spec_helper'

supported_os = on_supported_os
debian_11_facts = supported_os.fetch('debian-11-x86_64')
redhat_8_facts = supported_os.fetch('redhat-8-x86_64')

# Sorting compatibility requires a separate rspec-puppet child-class subject.
# rubocop:disable RSpec/MultipleDescribes

describe 'clamav', type: :class do
  context 'with clamd scalar, repeated, and empty values' do
    let(:facts) { debian_11_facts }
    let(:params) do
      {
        manage_clamd: true,
        clamd_default_options: {},
        clamd_options: {
          'ZLast' => ['first', '', :undef, false, 'second'],
          'AFirst' => 42,
          'EmptyString' => '',
          'UnsetOption' => :undef,
        },
      }
    end

    it { is_expected.to compile.with_all_deps }

    it 'preserves the ERB rendering contract' do
      is_expected.to contain_file('clamd.conf')
        .with_content(%r{^AFirst 42$}m)
        .with_content(%r{^ZLast first\nZLast false\nZLast second$}m)
        .without_content(%r{^EmptyString\s}m)
        .without_content(%r{^UnsetOption\s}m)
    end
  end

  context 'with freshclam values' do
    let(:facts) { debian_11_facts }
    let(:params) do
      {
        manage_freshclam: true,
        freshclam_default_options: {},
        freshclam_options: {
          'BooleanOption' => true,
          'RepeatedOption' => ['first', 'second'],
        },
      }
    end

    it do
      is_expected.to contain_file('freshclam.conf')
        .with_content(%r{^BooleanOption true$}m)
        .with_content(%r{^RepeatedOption first\nRepeatedOption second$}m)
    end
  end

  context 'with milter values' do
    let(:facts) { redhat_8_facts }
    let(:params) do
      {
        manage_repo: false,
        manage_clamav_milter: true,
        milter_default_options: {},
        clamav_milter_options: {
          'BooleanOption' => false,
          'RepeatedOption' => ['first', 'second'],
        },
      }
    end

    it do
      is_expected.to contain_file('clamav-milter.conf')
        .with_content(%r{^BooleanOption false$}m)
        .with_content(%r{^RepeatedOption first\nRepeatedOption second$}m)
    end
  end
end

describe 'clamav::clamd', type: :class do
  let(:facts) { debian_11_facts }
  let(:params) { { sort_options: false } }
  let(:pre_condition) do
    <<~PUPPET
      class { 'clamav':
        clamd_default_options => {},
        clamd_options         => {
          'ZLast'  => 'first',
          'AFirst' => 'second',
        },
      }
    PUPPET
  end

  it 'preserves caller insertion order when sorting is disabled' do
    is_expected.to contain_file('clamd.conf')
      .with_content(%r{^ZLast first\nAFirst second$}m)
  end
end

# rubocop:enable RSpec/MultipleDescribes

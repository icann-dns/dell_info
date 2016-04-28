# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'opendnssec class' do
  context 'defaults' do
    it 'work with no errors' do
      pp = <<-EOF
      class {'::dell_info':
        api_key => 'aaaaaaaa'
      }
      EOF
      apply_manifest(pp, catch_failures: true)
      expect(apply_manifest(pp, catch_failures: true).exit_code).to eq 0
    end
    describe file('/etc/dell_info.yaml') do
      it { is_expected.to exist }
    end
  end
end

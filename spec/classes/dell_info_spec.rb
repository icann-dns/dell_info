require 'spec_helper'

describe 'dell_info' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  # include_context :hiera
  let(:node) { 'dell_info.example.com' }

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end

  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      api_key: 'AAAAAAAAAAAA',
      # sandbox: false,
      # force: false,
      # extra_facts: [],

    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  # This will need to get moved
  # it { pp catalogue.resources }
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('dell_info') }
        it do
          is_expected.to contain_file('/etc/dell_info.yaml').with_ensure(
            'present'
          ).with_content(
            %r{
            api_key:\sAAAAAAAAAAAA\n
            force:\sfalse\n
            sandbox:\sfalse\n
            extra_facts:
            }x
          )
        end
        it do
          is_expected.to contain_file('/var/cache/facts.d').with_ensure(
            'directory',
          )
        end
      end
      describe 'Change Defaults' do
        context 'api_key' do
          before { params.merge!(api_key: 'BBBBBBBBBBBB') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/etc/dell_info.yaml').with_ensure(
              'present'
            ).with_content(
              %r{
              api_key:\sBBBBBBBBBBBB\n
              force:\sfalse\n
              sandbox:\sfalse\n
              extra_facts:
              }x
            )
          end
        end
        context 'sandbox' do
          before { params.merge!(sandbox: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/etc/dell_info.yaml').with_ensure(
              'present'
            ).with_content(
              %r{
              api_key:\sAAAAAAAAAAAA\n
              force:\sfalse\n
              sandbox:\strue\n
              extra_facts:
              }x
            )
          end
        end
        context 'force' do
          before { params.merge!(force: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/etc/dell_info.yaml').with_ensure(
              'present'
            ).with_content(
              %r{
              api_key:\sAAAAAAAAAAAA\n
              force:\strue\n
              sandbox:\sfalse\n
              extra_facts:
              }x
            )
          end
        end
        context 'extra_facts' do
          before { params.merge!(extra_facts: ['foobar']) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/etc/dell_info.yaml').with_ensure(
              'present'
            ).with_content(
              %r{
              api_key:\sAAAAAAAAAAAA\n
              force:\sfalse\n
              sandbox:\sfalse\n
              extra_facts:\n
              -\sfoobar
              }x
            )
          end
        end
      end
      describe 'check bad type' do
        context 'api_key' do
          before { params.merge!(api_key: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'sandbox' do
          before { params.merge!(sandbox: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'force' do
          before { params.merge!(force: 'foobar') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'extra_facts' do
          before { params.merge!(extra_facts: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end

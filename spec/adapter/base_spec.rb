require 'spec_helper'
require 'saorin/adapters/servers/base'

describe Saorin::Adapters::Servers::Base do
  it_should_behave_like 'rpc call' do
    let(:process) do
      handler = Saorin::Test::Handler.new
      server = Saorin::Adapters::Servers::Base.new handler
      proc do |input|
        server.process_request input
      end
    end
  end
end

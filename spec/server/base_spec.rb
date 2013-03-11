require 'spec_helper'
require 'saorin/server/base'

describe Saorin::Server::Base do
  it_should_behave_like 'rpc call' do
    let(:process) do
      handler = Saorin::Test::Handler.new
      server = Saorin::Server::Base.new handler
      proc do |input|
        server.process_request input
      end
    end
  end
end

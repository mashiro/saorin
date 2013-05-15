require 'spec_helper'

describe Saorin::Server::Base do
  it_should_behave_like 'returning valid response' do
    let(:process) do
      handler = Saorin::Test::Handler.new
      class VanillaServer
        include Saorin::Server::Base
      end
      server = VanillaServer.new handler
      proc do |input|
        data = server.process_request input
        data && JSON.load(data)
      end
    end
  end
end

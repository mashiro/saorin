require 'spec_helper'
require 'saorin/test'
require 'saorin/server/rack'

describe Saorin::Server::Rack do
  include Saorin::Test

  let(:server_adapter) { :rack }
  include_context 'setup rpc server client'
  it_should_behave_like 'rpc server client'
end

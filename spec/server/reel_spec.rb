require 'spec_helper'
require 'saorin/test'
require 'saorin/server/reel'

describe Saorin::Server::Reel do
  include Saorin::Test

  let(:server_adapter) { :reel }
  include_context 'setup rpc server client'
  it_should_behave_like 'rpc server client'
end

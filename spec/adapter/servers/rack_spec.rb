require 'spec_helper'
require 'saorin/test'
require 'saorin/adapters/servers/rack'

describe Saorin::Adapters::Servers::Rack do
  include Saorin::Test

  let(:server_adapter) { :rack }
  include_context 'setup rpc server client'
  it_should_behave_like 'rpc server client'
end

require 'saorin/adapters/clients'

module Saorin
  class Client
    class << self
      def new(options = {}, &block)
        adapter = options.delete(:adapter) || :faraday
        adapter_class = Saorin::Adapters::Clients.guess adapter
        adapter_class.new options, &block
      end
    end
  end
end

require 'saorin/adapters/servers'

module Saorin
  class Server
    class << self
      def new(handler, options = {}, &block)
        adapter = options.delete(:adapter) || :rack
        adapter_class = Saorin::Adapters::Servers.guess adapter
        adapter_class.new handler, options, &block
      end

      alias_method :start, :new
    end
  end
end

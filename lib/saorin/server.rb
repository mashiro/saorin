require 'saorin/registerable'
require 'saorin/server/base'

module Saorin
  module Server
    include Registerable
    self.load_path = 'saorin/server'

    class << self
      def new(handler, options = {})
        adapter = options.delete(:adapter) || :rack
        adapter_class = guess adapter
        adapter_class.new handler, options
      end

      def start(handler, options = {}, &block)
        new(handler, options).start(&block)
      end
    end
  end
end

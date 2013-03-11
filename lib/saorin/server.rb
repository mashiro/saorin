require 'saorin/registerable'

module Saorin
  module Server
    include Registerable
    self.load_path = 'saorin/server'

    class << self
      def new(handler, options = {}, &block)
        adapter = options.delete(:adapter) || :rack
        adapter_class = guess adapter
        adapter_class.new handler, options, &block
      end
      alias_method :start, :new
    end
  end
end

require 'saorin/registerable'
require 'saorin/client/base'

module Saorin
  module Client
    include Registerable
    self.load_path = 'saorin/client'

    class << self
      def new(options = {}, &block)
        adapter = options[:adapter] || :faraday
        adapter_class = guess adapter
        adapter_class.new options, &block
      end
    end
  end
end

require 'saorin/error'

module Saorin
  module Adapters
    module Registerable
      class << self
        def included(base)
          base.extend ClassMethods
        end
      end

      module ClassMethods
        attr_accessor :load_path

        def adapters
          @adapters ||= {}
        end

        def register(key, adapter)
          adapters[key.to_s] = adapter
        end

        def guess(key)
          key = key.to_s
          require "#{load_path}/#{key}"
          adapter = adapters[key]
          raise AdapterNotFound, key unless adapter
          adapter
        end
      end
    end
  end
end

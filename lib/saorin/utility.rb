module Saorin
  module Utility
    class << self
      def symbolized_keys(hash)
        hash = hash.dup
        hash.keys.each do |key|
          if key.is_a?(::String)
            hash[key.to_sym] = hash.delete(key)
          end
        end
        hash
      end
    end
  end
end

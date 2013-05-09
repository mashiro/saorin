require 'saorin/utility'

module Saorin
  module Dumpable
    def to_json(*args)
      options = Saorin::Utility.extract_options!(args)
      MultiJson.dump to_h, options
    end
  end
end

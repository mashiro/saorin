module Saorin
  module Formatter
    def default_formatter
      MultiJson
    end

    def formatter
      @formatter ||= (@options[:formatter] || default_formatter)
    end
  end
end

require 'multi_json'

module Saorin
  class Error < StandardError
  end

  class RPCError < Error
    attr_reader :code, :data

    def initialize(message, options = {})
      super message
      @code = options[:code]
      @data = options[:data]
    end

    def to_h
      h = {}
      h['code'] = code
      h['message'] = message
      h['data'] = data if data
      h
    end

    def to_json(*args)
      options = args.last.is_a?(::Hash) ? args.pop : {}
      MultiJson.dump to_h, options
    end
  end

  # code  message   meaning
  # -32700  Parse error   Invalid JSON was received by the server.  An error occurred on the server while parsing the JSON text.
  # -32600  Invalid Request   The JSON sent is not a valid Request object.
  # -32601  Method not found  The method does not exist / is not available.
  # -32602  Invalid params  Invalid method parameter(s).
  # -32603  Internal error  Internal JSON-RPC error.
  # -32000 to -32099  Server error  Reserved for implementation-defined server-errors.

  JSON_RPC_ERRORS = [
    [-32700, :ParseError, 'Parse error'],
    [-32600, :InvalidRequest, 'Invalid Request'],
    [-32601, :MethodNotFound, 'Method not found'],
    [-32602, :InvalidParams, 'Invalid params'],
    [-32603, :InternalError, 'Internal error'],
  ]
  
  JSON_RPC_ERRORS.each do |code, name, message|
    class_eval <<-EOS
      class #{name} < RPCError
        def initialize(message = nil, options = {})
          options[:code] = #{code}
          super message || '#{message}', options
        end
      end
    EOS
  end

  class ServerError < RPCError
    def initialize(message, options = {})
      options[:code] ||= -32000
      super message, options
    end
  end

  class << self
    def code_to_error(code)
      if (-32099..-32000).include?(code)
        ServerError
      else
        @map ||= Hash[JSON_RPC_ERRORS.map { |c, n, m| [c, const_get(n)] }]
        @map[code]
      end
    end
  end

  class InvalidResponse < Error
  end

  class AdapterNotFound < Error
  end
end

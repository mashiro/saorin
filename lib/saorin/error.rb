require 'multi_json'

module Saorin
  class Error < StandardError
  end

  class RPCError < Error
    attr_reader :code

    def initialize(code, message)
      @code = code
      super message
    end

    def to_h
      {'code' => code, 'message' => message}
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
        def initialize
          super #{code}, '#{message}'
        end
      end
    EOS
  end

  class ServerError < RPCError
    def initialize(e, code = -32000)
      super code, e.to_s
    end
  end

  class << self
    def code_to_error(code)
      @map ||= Hash[JSON_RPC_ERRORS.map { |c, n, m| [c, const_get(n)] }]
      @map[code]
    end
  end

  class InvalidResponse < Error
  end

  class AdapterNotFound < Error
  end
end

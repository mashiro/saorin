require 'saorin'
require 'saorin/error'
require 'multi_json'

module Saorin
  class Response
    attr_accessor :version, :result, :error, :id

    def initialize(result, error, id = nil, version = Saorin::JSON_RPC_VERSION)
      @version = version
      @result = result
      @error = error
      @id = id
    end

    def error?
      !!@error
    end

    def valid?
      return false unless (@result || @error) && !(@result && @error)
      return false unless [String].any? { |type| @version.is_a? type }
      return false unless [String, NilClass].any? { |type| @result.is_a? type }
      return false unless [Saorin::Error, Hash, NilClass].any? { |type| @error.is_a? type }
      return false unless [String, Numeric, NilClass].any? { |type| @id.is_a? type }
      return false unless @version == JSON_RPC_VERSION
      true
    end

    def validate
      raise Saorin::InvalidResponse unless valid?
    end

    def to_h
      h = {}
      h['jsonrpc'] = @version
      h['result'] = @result unless error?
      h['error'] = @error if error?
      h['id'] = id
      h
    end

    def to_json(*args)
      options = args.last.is_a?(::Hash) ? args.pop : {}
      MultiJson.dump to_h, options
    end

    def self.from_hash(hash)
      raise Saorin::InvalidResponse unless hash.is_a?(::Hash)
      new *hash.values_at('result', 'error', 'id', 'jsonrpc')
    end
  end
end

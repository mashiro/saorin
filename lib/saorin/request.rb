require 'saorin'
require 'saorin/error'
require 'multi_json'

module Saorin
  class Request
    attr_accessor :version, :method, :params, :id

    def initialize(method, params, id = nil, version = Saorin::JSON_RPC_VERSION)
      @version = version
      @method = method
      @params = params
      @id = id
    end

    def valid?
      return false unless @method && @version
      return false unless [String].any? { |type| @version.is_a? type }
      return false unless [String].any? { |type| @method.is_a? type }
      return false unless [Hash, Array, NilClass].any? { |type| @params.is_a? type }
      return false unless [String, Numeric, NilClass].any? { |type| @id.is_a? type }
      return false unless @version == JSON_RPC_VERSION
      return false unless !@method.start_with?('.')
      true
    end

    def validate
      raise Saorin::InvalidRequest unless valid?
    end

    def to_h
      h = {}
      h['jsonrpc'] = @version
      h['method'] = @method
      h['params'] = @params if @params && !@params.empty?
      h['id'] = @id
      h
    end

    def to_json(*args)
      options = args.last.is_a?(::Hash) ? args.pop : {}
      MultiJson.dump to_h, options
    end

    def self.from_hash(hash)
      raise Saorin::InvalidRequest unless hash.is_a?(::Hash)
      new *hash.values_at('method', 'params', 'id', 'jsonrpc')
    end
  end
end

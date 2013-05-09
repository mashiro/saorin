require 'saorin'
require 'saorin/error'
require 'saorin/utility'
require 'multi_json'

module Saorin
  class Request
    attr_accessor :version, :method, :params, :id

    def initialize(method, params, options = {})
      @version = options[:version] || Saorin::JSON_RPC_VERSION
      @method = method
      @params = params
      @id = options[:id]
      @notify = !options.has_key?(:id)
    end

    def notify?
      @notify
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
      h['id'] = @id unless notify?
      h
    end

    def to_json(*args)
      options = Saorin::Utility.extract_options!(args)
      MultiJson.dump to_h, options
    end

    def self.symbolized_keys(hash)
      hash.each do |k, v|
        if k.is_a? ::String
          hash[k.to_sym] = v
        end
      end
    end

    def self.from_hash(hash)
      raise Saorin::InvalidRequest unless hash.is_a?(::Hash)
      options = hash.dup
      method = options.delete('method')
      params = options.delete('params')
      new method, params, Saorin::Utility.symbolized_keys(options)
    end
  end
end

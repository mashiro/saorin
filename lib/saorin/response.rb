require 'saorin'
require 'saorin/error'
require 'saorin/dumpable'
require 'saorin/utility'

module Saorin
  class Response
    include Dumpable

    attr_accessor :version, :result, :error, :id

    def initialize(options = {})
      @version = options[:version] || Saorin::JSON_RPC_VERSION
      @result = options[:result]
      @error = options[:error]
      @id = options[:id]
    end

    def error?
      !!@error
    end

    def valid?
      return false unless !(@result && @error)
      return false unless [String].any? { |type| @version.is_a? type }
      return false unless [Object].any? { |type| @result.is_a? type }
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

    def self.from_hash(hash)
      raise Saorin::InvalidResponse unless hash.is_a?(::Hash)
      new Saorin::Utility.symbolized_keys(hash)
    end
  end
end

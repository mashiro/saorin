require 'saorin/error'
require 'saorin/request'
require 'saorin/response'
require 'saorin/formatter'
require 'saorin/client'

module Saorin
  module Client
    module Base
      module UUID
        def uuid
          require 'securerandom'
          SecureRandom.uuid
        end
      end

      include UUID
      include Formatter

      attr_reader :options

      def initialize(options = {})
        @options = options
      end

      def call(method, *args)
        apply Saorin::Request.new(method, args, :id => uuid)
      end

      def notify(method, *args)
        apply Saorin::Request.new(method, args)
      end

      def apply(request)
        response = send_request dump_request(request)
        content = process_response response
        raise content if content.is_a?(Saorin::RPCError)
        content
      end

      class Batch < ::Array
        include UUID
        attr_reader :client

        def initialize(client)
          super()
          @client = client
        end

        def call(method, *args)
          push Saorin::Request.new(method, args, :id => uuid)
        end

        def notify(method, *args)
          push Saorin::Request.new(method, args)
        end

        def apply
          return [] if empty?
          @client.apply(self) || []
        end
      end

      def batch
        Batch.new self
      end

      protected

      def send_request(content)
        raise NotImplementedError
      end

      def process_response(content)
        response = parse_response content
        if response.is_a?(::Array)
          response.map { |res| handle_response res }
        else
          handle_response response
        end
      rescue => e
        raise Saorin::InvalidResponse, e.to_s
      end

      def parse_response(content)
        return nil if content.nil? || content.empty?
        formatter.load content
      end

      def dump_request(request)
        formatter.dump request
      end

      def to_content(response)
        return nil if response.nil?
        if response.error?
          code, message, data = response.error.values_at('code', 'message', 'data')
          error_class = Saorin.code_to_error code
          raise Error, 'unknown error code' unless error_class
          error_class.new message, :code => code, :data => data
        else
          response.result
        end
      end

      def handle_response(hash)
        return nil if hash.nil?
        response = Response.from_hash(hash)
        response.validate
        to_content response
      end
    end
  end
end

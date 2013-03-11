require 'multi_json'
require 'saorin/request'
require 'saorin/response'
require 'saorin/client'

module Saorin
  module Client
    module Base
      CONTENT_TYPE = 'application/json'.freeze

      def initialize(options = {})
      end

      def call(method, *args)
        apply Saorin::Request.new(method, args, :id => seqid!)
      end

      def notify(method, *args)
        apply Saorin::Request.new(method, args)
      end

      def apply(request)
        response = send_request request.to_json
        content = process_response response
        raise content if content.is_a?(Saorin::RPCError)
        content
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
      rescue Saorin::InvalidResponse => e
        raise e
      rescue => e
        p e
        print e.backtrace.join("\t\n")
        raise Saorin::InvalidResponse, e.to_s
      end

      def parse_response(content)
        MultiJson.decode content
      rescue MultiJson::LoadError => e
        raise Saorin::InvalidResponse, e.to_s
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

      def seqid
        @@seqid ||= 0
      end

      def seqid=(value)
        @@seqid = value
        @@seqid = 0 if @@seqid >= (1 << 31)
        @@seqid
      end

      def seqid!
        id = self.seqid
        self.seqid += 1
        id
      end
    end
  end
end

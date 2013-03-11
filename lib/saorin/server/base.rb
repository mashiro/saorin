require 'saorin/error'
require 'saorin/request'
require 'saorin/response'
require 'saorin/server'

module Saorin
  module Server
    class Base
      attr_reader :handler, :allowed_methods

      def initialize(handler, options = {})
        @handler = handler
        @allowed_methods = options[:allowed_methods] || handler.public_methods(false)
        @allowed_methods.map! { |m| m.to_s }
      end

      def process_request(content)
        response = begin
                     request = parse_request content
                     if request.is_a?(::Array)
                       raise Saorin::InvalidRequest if request.empty?
                       responses = request.map { |req| handle_request(req) }
                       responses.compact!
                       responses.empty? ? nil : responses
                     else
                       handle_request(request)
                     end
                   rescue Saorin::Error => e
                     Response.new(:error => e)
                   end

        response && MultiJson.dump(response)
      end

      def parse_request(content)
        MultiJson.decode content
      rescue MultiJson::LoadError
        raise Saorin::ParseError
      end

      def handle_request(hash)
        begin
          request = Request.from_hash(hash)
          request.validate
          dispatch_request_with_trap_notification request
        rescue Saorin::InvalidRequest => e
          Response.new(:error => e)
        rescue Saorin::Error => e
          Response.new(:error => e, :id => request.id)
        rescue Exception => e
          options = {:error => Saorin::InternalError.new}
          options[:id] = request.id if request
          Response.new(options)
        end
      end

      def dispatch_request_with_trap_notification(request)
        result = dispatch_request request
        Response.new(:result => result, :id => request.id)
      ensure
        return nil if request.notify?
      end

      def dispatch_request(request)
        method = request.method.to_s
        params = request.params || []

        unless @allowed_methods.include?(method) && @handler.respond_to?(method)
          raise Saorin::MethodNotFound
        end

        begin
          if params.is_a?(::Hash)
            @handler.__send__ method, params
          else
            @handler.__send__ method, *params
          end
        rescue ArgumentError
          raise Saorin::InvalidParams
        rescue Exception => e
          raise Saorin::ServerError, e
        end
      end
    end
  end
end

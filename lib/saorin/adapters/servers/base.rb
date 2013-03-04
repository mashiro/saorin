require 'saorin/error'
require 'saorin/request'
require 'saorin/response'
require 'saorin/adapters/servers'

module Saorin
  module Adapters
    module Servers
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
                       Response.new(nil, e)
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
            result = dispatch_request request
            response = Response.new(result, nil, request.id)
            notify?(hash) ? nil : response
          rescue Saorin::InvalidRequest => e
            Response.new(nil, e)
          rescue Saorin::Error => e
            Response.new(nil, e, request.id)
          rescue Exception => e
            p e
            Response.new(nil, Saorin::InternalError.new, request && request.id)
          end
        end

        def notify?(hash)
          hash.is_a?(::Hash) && !hash.has_key?('id')
        end

        def dispatch_request(request)
          method = request.method.to_s
          params = request.params || []

          unless @allowed_methods.include?(method) &&
            @handler.respond_to?(method)
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
end

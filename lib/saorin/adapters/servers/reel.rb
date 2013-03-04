require 'saorin/adapters/servers/base'
require 'reel'

module Saorin
  module Adapters
    module Servers
      class Reel < Base
        DEFAULT_HEADERS = {
          'Content-Type' => 'application/json'
        }

        def initialize(handler, options = {}, &block)
          super handler, options

          server = ::Reel::Server.supervise(options[:host], options[:port], &method(:process))
          trap(:INT) { server.terminate; exit }
          sleep
        end

        def process(connection)
          while request = connection.request
            case request
            when ::Reel::Request
              response_body = ''
              response_body = process_request(request.body) if request.method.to_s.upcase == 'POST'
              request.respond ::Reel::Response.new(200, DEFAULT_HEADERS, response_body)
            end
          end
        end
      end

      register :reel, Reel
    end
  end
end

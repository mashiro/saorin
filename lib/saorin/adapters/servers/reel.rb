require 'saorin/adapters/servers/base'
require 'reel'

module Saorin
  module Adapters
    module Servers
      class Reel < Base
        DEFAULT_HEADERS = {
          'Content-Type' => 'application/json'
        }.freeze

        attr_reader :server

        def initialize(handler, options = {}, &block)
          super handler, options

          @server = ::Reel::Server.supervise(options[:host], options[:port], &method(:process))
          trap(:INT) { @server.terminate; exit }
          sleep unless options[:nonblock]
        end

        def process(connection)
          while request = connection.request
            case request
            when ::Reel::Request
              response_body = process_request(request.body) if request.method.to_s.upcase == 'POST'
              response_body ||= ''
              request.respond :ok, DEFAULT_HEADERS.dup, response_body
            end
          end
        end
      end

      register :reel, Reel
    end
  end
end

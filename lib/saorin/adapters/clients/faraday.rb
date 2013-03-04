require 'saorin/adapters/clients/base'
require 'faraday'

module Saorin
  module Adapters
    module Clients
      class Faraday < Base
        attr_reader :connection

        def initialize(options = {}, &block)
          super options

          @connection = ::Faraday::Connection.new(options) do |builder|
            builder.adapter ::Faraday.default_adapter
            builder.response :raise_error
            block.call builder if block
          end
        end

        def send_request(content)
          response = @connection.post do |req|
            req.headers[:content_type] = CONTENT_TYPE
            req.body = content
          end
          response.body
        end
      end

      register :faraday, Faraday
    end
  end
end

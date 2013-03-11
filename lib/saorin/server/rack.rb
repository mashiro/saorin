require 'saorin/server/base'
require 'rack'

module Saorin
  module Server
    class Rack < Base
      DEFAULT_HEADERS = {
        'Content-Type' => 'application/json'
      }.freeze

      def initialize(handler, options = {}, &block)
        super handler, options

        ::Rack::Server.start({
          :app => self,
          :Host => options[:host],
          :Port => options[:port],
        }.merge(options))
      end

      def call(env)
        request = ::Rack::Request.new(env)
        response = ::Rack::Response.new([], 200, DEFAULT_HEADERS.dup)
        response.write process_request(request.body.read) if request.post?
        response.finish
      end
    end

    register :rack, Rack
  end
end

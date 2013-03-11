require 'saorin/server/base'
require 'rack'

module Saorin
  module Server
    class Rack
      include Base

      DEFAULT_HEADERS = {
        'Content-Type' => 'application/json'
      }.freeze

      attr_reader :server

      def initialize(handler, options = {})
        super
        @server = ::Rack::Server.new({
          :app => self,
          :Host => options[:host],
          :Port => options[:port],
        }.merge(@options))
      end

      def start(&block)
        @server.start &block
      end

      def shutdown
        if @server.server.respond_to?(:shutdown)
          @server.server.shutdonw
        end
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

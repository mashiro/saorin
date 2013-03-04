require 'multi_json'
require 'saorin/request'
require 'saorin/response'
require 'saorin/adapters/clients'

module Saorin
  module Adapters
    module Clients
      class Base
        def initialize(options = {})
        end

        def call_single(method, *args)
          request = Saorin::Request.new method, args, seqid!
          response = send_request request.to_json
          content = process_response response
          raise content if content.is_a?(Saorin::RPCError)
          content
        end

        alias_method :call, :call_single

        def call_multi(*args)
          requests = args.map do |arg|
            request_args = arg.to_a.flatten
            method = request_args.shift
            Saorin::Request.new method, request_args, seqid!
          end
          response = send_request requests.to_json
          process_response response
        end

        def send_request(content)
          raise NotImplementedError
        end

        def process_response(content)
          response = parse_response content
          if response.is_a?(::Array)
            response.map { |res| to_content handle_response(res) }
          else
            to_content handle_response(response)
          end
        rescue => e
          raise Saorin::InvalidResponse, e.to_s
        end

        def parse_response(content)
          MultiJson.decode content
        rescue MultiJson::LoadError => e
          raise Saorin::InvalidResponse, e.to_s
        end

        def to_content(res)
          if res.error?
            code = res.error['code']
            error_class = Saorin.code_to_error code
            error_class.new
          else
            res.result
          end
        end

        def handle_response(hash)
          response = Response.from_hash(hash)
          response.validate
          response
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
end

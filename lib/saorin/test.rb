require 'saorin/server'
require 'saorin/client'
require 'thread'
require 'logger'
require 'rspec'

module Saorin
  module Test
    class Handler
      def identity(value)
        value
      end

      def subtract1(a, b)
        a - b
      end

      def subtract2(options)
        options['minuend'] - options['subtrahend']
      end

      def update(a, b, c, d, e)
        'OK'
      end

      def sum(a, b, c)
        a + b + c
      end

      def notify_hello(a)
        'OK'
      end

      def get_data
        ['hello', 5]
      end

      def notify_sum(a, b, c)
        a + b + c
      end
    end

    HOST = '127.0.0.1'
    PORT = 45339

    attr_reader :pid
    attr_reader :server
    attr_reader :client

    def create_test_server(options = {})
      @pid = Process.fork do
        @server = Saorin::Server.new(Handler.new, {
          :host => HOST,
          :port => PORT,
          :Logger => Logger.new('/dev/null'),
          :AccessLog => [],
        }.merge(options))
        @server.start
      end
      sleep 1
    end

    def shutdown_test_server
      Process.kill :TERM, @pid
    end

    def create_test_client(options = {})
      @client = Saorin::Client.new({
        :url => "http://127.0.0.1:#{PORT}"
      }.merge(options))
    end

    def test_call(*args)
      @client.call *args
    end

    def test_notify(*args)
      @client.notify *args
    end

    def test_batch
      @client.batch
    end

    shared_context 'setup rpc server client' do |options|
      before(:all) do
        create_test_server options[:server] || {}
        create_test_client options[:client] || {}
      end
      after(:all) do
        shutdown_test_server
      end
    end

    shared_examples 'rpc communicatable' do
      context 'call' do
        it 'string' do
          v = '123'
          expect(test_call('identity', v)).to eq v
        end

        it 'number' do
          v = 123
          expect(test_call('identity', v)).to eq v
        end

        it 'array' do
          v = [1, 2, 3]
          expect(test_call('identity', v)).to eq v
        end

        it 'hash' do
          v = {'foo' => 1, 'bar' => 2}
          expect(test_call('identity', v)).to eq v
        end

        it 'nil' do
          v = nil
          expect(test_call('identity', v)).to eq v
        end

        it 'not found' do
          expect { test_call('xx') }.to raise_error MethodNotFound
        end

        it 'invalid params' do
          expect { test_call('identity', 1, 2, 3, 4, 5) }.to raise_error InvalidParams
        end
      end

      context 'notify' do
        it 'string' do
          v = '123'
          expect(test_notify('identity', v)).to eq nil
        end

        it 'not found' do
          expect(test_notify('xxx')).to eq nil
        end

        it 'invalid params' do
          expect(test_notify('identity', 1, 2, 3, 4, 5)).to eq nil
        end
      end

      context 'batch' do
        it 'batch call' do
          b = test_batch
          b.call 'identity', 1
          b.call 'identity', '2'
          b.call 'identity', [3]
          b.call 'xxx'
          expect(b.apply).to eq [1, '2', [3], MethodNotFound]
        end

        it 'batch call with notify' do
          b = test_batch
          b.call 'identity', 1
          b.notify 'identity', '2'
          b.call 'identity', [3]
          b.notify 'xxx'
          expect(b.apply).to eq [1, [3]]
        end

        it 'all notify' do
          b = test_batch
          b.notify 'identity', 1
          b.notify 'identity', '2'
          b.notify 'identity', [3]
          b.notify 'xxx'
          expect(b.apply).to eq []
        end

        it 'empty' do
          b = test_batch
          expect(b.apply).to eq []
        end
      end
    end
  end
end

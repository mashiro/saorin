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
        @server = Saorin::Server.start(Handler.new, {
          :host => HOST,
          :port => PORT,
          :Logger => Logger.new('/dev/null'),
          :AccessLog => [],
        }.merge(options))
      end
      sleep 3
    end

    def shutdown_test_server
      Process.kill :INT, @pid
      sleep 3
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

    shared_context 'setup rpc server client' do
      let(:server_adapter) {}
      let(:client_adapter) {}
      before(:all) do
        create_test_server :adapter => server_adapter
        create_test_client :adapter => client_adapter
      end
      after(:all) do
        shutdown_test_server
      end
    end

    shared_examples 'rpc server client' do
      it 'string' do
        value = '123'
        test_call('identity', value).should eq value
      end

      it 'number' do
        value = 123
        test_call('identity', value).should eq value
      end

      it 'array' do
        value = [1, 2, 3]
        test_call('identity', value).should eq value
      end

      it 'hash' do
        value = {'foo' => 1, 'bar' => 2}
        test_call('identity', value).should eq value
      end

      it 'nil' do
        value = nil
        test_call('identity', value).should eq value
      end

      it 'not found' do
        lambda { test_call('xxx') }.should raise_error MethodNotFound
      end

      it 'invalid params' do
        lambda { test_call('identity', 1, 2, 3, 4, 5) }.should raise_error InvalidParams
      end
    end
  end
end

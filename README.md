# Saorin [![Build Status](https://travis-ci.org/mashiro/saorin.png?branch=master)](https://travis-ci.org/mashiro/saorin)

JSON-RPC server and client library.

## Installation

Add this line to your application's Gemfile:

    gem 'saorin'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install saorin

## Usage

### Server
```ruby
class Handler
  def hello(name)
    "Hello #{name}!"
  end 
end

Saorin::Server.start Handler.new, :host => '0.0.0.0', :port => 8080
```

### Client
```ruby
client = Saorin::Client.new :url => 'http://localhost:8080'
client.call :hello, 'trape' #=> 'Hello trape!'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

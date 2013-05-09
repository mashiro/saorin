# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'saorin/version'

Gem::Specification.new do |gem|
  gem.name          = 'saorin'
  gem.version       = Saorin::VERSION
  gem.authors       = ['mashiro']
  gem.email         = ['mail@mashiro.org']
  gem.description   = %q{JSON-RPC 2.0 implementation}
  gem.summary       = %q{JSON-RPC 2.0 server and client implementation for any protocols}
  gem.homepage      = 'https://github.com/mashiro/saorin'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'multi_json'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rack'
  gem.add_development_dependency 'faraday'
end

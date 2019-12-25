# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'saorin/version'

Gem::Specification.new do |spec|
  spec.name          = 'saorin'
  spec.version       = Saorin::VERSION
  spec.authors       = ['mashiro']
  spec.email         = ['mail@mashiro.org']
  spec.description   = %q{JSON-RPC 2.0 implementation}
  spec.summary       = %q{JSON-RPC 2.0 server and client implementation for any protocols}
  spec.homepage      = 'https://github.com/mashiro/saorin'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'multi_json'
  spec.add_development_dependency 'rake', '~> 13.0.1'
  spec.add_development_dependency 'rspec', '~> 3.9.0'
  spec.add_development_dependency 'rspec-its', '~> 1.3.0'
  spec.add_development_dependency 'rspec-collection_matchers', '~> 1.2.0'
  spec.add_development_dependency 'rack', '~> 2.0.8'
  spec.add_development_dependency 'faraday', '~> 0.17.1'
end

# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'saorin/version'

Gem::Specification.new do |gem|
  gem.name          = 'saorin'
  gem.version       = Saorin::VERSION
  gem.authors       = ['mashiro']
  gem.email         = ['mail@mashiro.org']
  gem.description   = %q{JSON-RPC 2.0 implementation for ruby}
  gem.summary       = %q{JSON-RPC 2.0 implementation for ruby}
  gem.homepage      = ''

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'multi_json'
  gem.add_dependency 'faraday'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
end

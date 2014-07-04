# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rabbit_rpc/version'

Gem::Specification.new do |spec|
  spec.name          = "rabbit_rpc"
  spec.version       = RabbitRPC::VERSION
  spec.authors       = ["Sohaib Bhatti"]
  spec.email         = ["sohaibbbhatti@gmail.com"]
  spec.description   = %q{Framework for developing services and workers using RabbitMQ}
  spec.summary       = %q{Ruby RabbitMQ framework}
  spec.homepage      = "https://github.com/sohaibbhatti/rabbit_rpc"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "i18n"
  spec.add_dependency "msgpack", "~> 0.5.8"
  spec.add_dependency "activesupport", "~> 3.0.0"
  spec.add_dependency "bunny", "~> 0.10.8"
  spec.add_dependency "amqp", "~> 1.0.4"

  spec.add_development_dependency "rspec", "~> 2.14.1"
  spec.add_development_dependency "evented-spec"
end

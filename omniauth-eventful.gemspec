# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth-eventful/version'

Gem::Specification.new do |spec|
  spec.name          = "omniauth-eventful"
  spec.version       = Omniauth::Eventful::VERSION
  spec.authors       = ["Kelley Stephens"]
  spec.email         = ["kelley@kelleystephens.com"]
  spec.summary       = %q{An Eventful strategy for OmniAuth}
  spec.description   = %q{An Eventful strategy for OmniAuth}
  spec.homepage      = "https://github.com/kelleystephens/omniauth-eventful"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'omniauth', '~> 1.0'
  spec.add_dependency 'omniauth-oauth', '~> 1.0'
  spec.add_dependency "multi_xml", "~> 0.5"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec', '~> 2.7'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'pry'
end

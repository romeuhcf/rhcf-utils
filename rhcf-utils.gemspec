# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rhcf/utils/version'

Gem::Specification.new do |spec|
  spec.name          = "rhcf-utils"
  spec.version       = Rhcf::Utils::VERSION
  spec.authors       = ["Romeu Fonseca"]
  spec.email         = ["romeu.hcf@gmail.com"]
  spec.summary       = %q{Personal Ruby Utility Tools.}
  spec.description   = %q{Personal set of ruby recurrent utility tools.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "pry-debugger"
end

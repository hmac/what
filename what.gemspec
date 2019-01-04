# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "what/version"

Gem::Specification.new do |spec|
  spec.name          = "what"
  spec.version       = What::VERSION
  spec.authors       = ["Harry Maclean"]
  spec.email         = ["harryjmaclean@gmail.com"]
  spec.description   = "A job queue that runs on PostgreSQL 9.5+."
  spec.summary       = "A PostgreSQL-based Job Queue"
  spec.homepage      = "https://github.com/hmac/what"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = ["what"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # Needed to handle intervals in the VariableRetry strategy
  spec.add_dependency "activesupport", "~> 5.0"

  spec.add_development_dependency "activerecord", "~> 5.0"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "pg", ">= 0.20", "< 2.0"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "rubocop", "~> 0.49"
  spec.add_development_dependency "sequel", ">= 5.0", "< 6.0"
  spec.add_development_dependency "timecop", "~> 0.8"
end

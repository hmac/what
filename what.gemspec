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

  spec.add_development_dependency "activejob"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "pg", ">= 0.20", "< 2.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "sequel"
  spec.add_development_dependency "timecop"
end

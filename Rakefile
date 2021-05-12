# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RuboCop::RakeTask.new("rubocop") do |task|
  task.fail_on_error = true
  task.patterns = [
    "lib/**/*.rb",
    "spec/**/*.rb",
    "Rakefile"
  ]
end

RSpec::Core::RakeTask.new(:spec)
task(default: %i[rubocop spec])

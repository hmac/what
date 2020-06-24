# frozen_string_literal: true

require "pry"
require "what"
require "active_record"
require "sequel"
require "timecop"

require "prepare"
require "support"

RSpec.configure do |config|
  config.around(:each) do |example|
    What.connection.execute_literal("TRUNCATE what_jobs, payments")
    example.run
    What.connection.execute_literal("TRUNCATE what_jobs, payments")
  end
end

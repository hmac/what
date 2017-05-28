# frozen_string_literal: true

require "pry"
require "what"

What::Connection.connection = PG::Connection.new(dbname: "what_test")
What::Connection.connection.type_map_for_results =
  PG::BasicTypeMapForResults.new(What::Connection.connection)

RSpec.configure do |config|
  config.around(:each) do |example|
    What::Connection.execute("TRUNCATE what_jobs, payments")
    example.run
    What::Connection.execute("TRUNCATE what_jobs, payments")
  end
end

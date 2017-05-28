# frozen_string_literal: true

require "pry"
require "what"
require "active_record"

ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  database: "what_test"
)
What::Connection.connection = ActiveRecord::Base.connection

RSpec.configure do |config|
  config.around(:each) do |example|
    What::Connection.execute("TRUNCATE what_jobs, payments")
    example.run
    What::Connection.execute("TRUNCATE what_jobs, payments")
  end
end

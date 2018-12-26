# frozen_string_literal: true

require "pry"
require "what"
require "active_record"
require "timecop"

require "support"

ActiveRecord::Base.establish_connection(adapter: "postgresql")
What.configure do |config|
  config.connection =
    What::Connection::ActiveRecord.new(ActiveRecord::Base.connection)
end

RSpec.configure do |config|
  config.around(:each) do |example|
    What.connection.execute("TRUNCATE what_jobs, payments")
    example.run
    What.connection.execute("TRUNCATE what_jobs, payments")
  end
end

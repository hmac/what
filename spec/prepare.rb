# frozen_string_literal: true

require "active_record"

require "what"
require "what/migrations/v1"
require "what/connection/active_record"

ActiveRecord::Base.establish_connection(adapter: "postgresql")
What.configure do |config|
  config.connection =
    What::Connection::ActiveRecord.new(ActiveRecord::Base.connection)
end

ActiveRecord::Migration.run(What::Migrations::V1)

What.connection.execute_literal("DROP TABLE IF EXISTS payments")
What.connection.execute_literal("CREATE TABLE payments (amount integer)")

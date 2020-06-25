# frozen_string_literal: true

require "active_record"

require "what"
require "what/connection/active_record"

ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
What.configure do |config|
  config.connection =
    What::Connection::ActiveRecord.new(ActiveRecord::Base.connection)
end

require "what/migrations/v1"

begin
  ActiveRecord::Migration.run(What::Migrations::V1)
rescue ActiveRecord::StatementInvalid => e
  raise(e) unless e.message.include?(PG::DuplicateTable.name)
end

What.connection.execute_literal("DROP TABLE IF EXISTS payments")
What.connection.execute_literal("CREATE TABLE payments (amount integer)")

# frozen_string_literal: true

require "what"
require "what/migrations/v1"

ActiveRecord::Base.establish_connection(adapter: "postgresql")
What.configure do |config|
  config.connection =
    What::Connection::ActiveRecord.new(ActiveRecord::Base.connection)
end

ActiveRecord::Migration.run(What::Migrations::V1)

What.connection.execute("DROP TABLE IF EXISTS payments")
What.connection.execute("CREATE TABLE payments (amount integer)")

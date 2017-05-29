# frozen_string_literal: true

require "what"
require "what/migrations/v1"

ActiveRecord::Base.establish_connection(adapter: "postgresql")
What::Connection.connection = ActiveRecord::Base.connection

ActiveRecord::Migration.run(What::Migrations::V1)

What::Connection.execute("DROP TABLE IF EXISTS payments")
What::Connection.execute("CREATE TABLE payments (amount integer)")

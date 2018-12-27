# frozen_string_literal: true

require_relative "support/create_payment"
require_relative "support/payment"
require_relative "support/blow_up"
require_relative "support/blow_up_with_retry"
require_relative "support/what_job"

What.configure { |config| config.logger = Logger.new(STDOUT) }

# We need an AR connection, even if What isn't using it, to use the helper
# models like Payment and WhatJob
ActiveRecord::Base.establish_connection(adapter: "postgresql", pool: 20)

# Support class for the Sequel connection adapter
class SequelSupport
  def initialize
    @db = Sequel.connect(adapter: "postgres", max_connections: 20)
    @conn = What::Connection::Sequel.new(@db)
    configure
  end

  def configure
    What.configure { |config| config.connection = @conn }
  end

  def with_connection
    @db.synchronize { yield @conn }
  end
end

# Support class for the ActiveRecord connection adapter
class ActiveRecordSupport
  def initialize
    @pool = ActiveRecord::Base.connection_pool
    configure
  end

  def configure
    What.configure do |config|
      config.connection =
        What::Connection::ActiveRecord.new(ActiveRecord::Base.connection)
    end
  end

  def with_connection
    conn = @pool.checkout
    yield What::Connection::ActiveRecord.new(conn)
    @pool.checkin(conn)
  end
end

AdapterSupport =
  (ENV["ADAPTER"] == "sequel" ? SequelSupport : ActiveRecordSupport).new

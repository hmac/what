# frozen_string_literal: true

require "pg"

module What
  class Connection
    def self.transaction(&blk)
      @connection.transaction(&blk)
    end

    def self.execute(sql, params=[])
      @connection.exec_params(sql, params)
    end

    def self.connection
      @connection ||= raise "Connection not established"
    end

    def self.connection=(connection)
      @connection = connection
    end
  end
end

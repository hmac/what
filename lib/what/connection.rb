# frozen_string_literal: true

module What
  class Connection
    def self.transaction(&blk)
      @connection.transaction(&blk)
    end

    def self.execute(sql, raw_params=[])
      params = raw_params.map do |name, value|
        ActiveRecord::Relation::QueryAttribute.new(name, value, ActiveRecord::Type.default_value)
      end
      @connection.exec_query(sql, "", params)
    end

    def self.connection
      @connection ||= raise "Connection not established"
    end

    def self.connection=(connection)
      @connection = connection
    end
  end
end

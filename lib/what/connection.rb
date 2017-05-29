# frozen_string_literal: true

require "active_record"

module What
  # Provides a small API for interacting with the database
  class Connection
    class << self
      attr_accessor :connection

      def transaction(&blk)
        @connection.transaction(&blk)
      end

      def execute(sql, raw_params = [])
        params = raw_params.map do |name, value|
          ActiveRecord::Relation::QueryAttribute.new(
            name,
            value,
            ActiveRecord::Type.default_value
          )
        end
        @connection.exec_query(sql, "", params)
      end
    end
  end
end

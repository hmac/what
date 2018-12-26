# frozen_string_literal: true

require "active_record"

module What
  module Connection
    # A connection adapter for ActiveRecord
    class ActiveRecord
      def initialize(connection)
        @connection = connection
      end

      def transaction(&blk)
        @connection.transaction(&blk)
      end

      def execute(sql, raw_params = [])
        params = raw_params.map do |name, value|
          ::ActiveRecord::Relation::QueryAttribute.new(
            name,
            value,
            ::ActiveRecord::Type.default_value
          )
        end
        @connection.exec_query(sql, "", params)
      end
    end
  end
end

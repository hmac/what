# frozen_string_literal: true

require "sequel"
require "active_support/core_ext/integer"

module What
  module Connection
    # A connection adapter for Sequel
    class Sequel
      def initialize(connection)
        @connection = connection
        @connection.extension(:pg_json)
        @connection.extension(:date_arithmetic)
      end

      def transaction(&blk)
        @connection.transaction(&blk)
      end

      def execute_literal(sql)
        @connection[sql].all
      end

      # @param queues [Array<String>]
      # @return [Hash, nil]
      def get_job(queues)
        @connection[:what_jobs]
          .for_update
          .skip_locked
          .where(runnable: true, queue: queues)
          .where { run_at < ::Sequel::CURRENT_TIMESTAMP }
          .first
          &.transform_values { |val| convert_json_fields(val) }
      end

      # @param id [String]
      # @return nil
      def destroy_job(id)
        @connection[:what_jobs].where(id: id).delete
        nil
      end

      def enqueue(job_class:, args:, queue:, run_at:)
        @connection[:what_jobs].insert(
          job_class: job_class,
          args: ::Sequel.pg_json(args),
          queue: queue,
          run_at: run_at || ::Sequel::CURRENT_TIMESTAMP,
          runnable: true
        )
      end

      def mark_as_failed(id:, last_error:)
        @connection[:what_jobs].where(id: id).update(
          runnable: false,
          failed_at: ::Sequel::CURRENT_TIMESTAMP,
          last_error: last_error,
          error_count: ::Sequel[:error_count] + 1
        )
      end

      def retry_at_interval(id:, last_error:, interval:)
        @connection[:what_jobs].where(id: id).update(
          runnable: true,
          failed_at: ::Sequel::CURRENT_TIMESTAMP,
          last_error: last_error,
          error_count: ::Sequel[:error_count] + 1,
          run_at: ::Sequel.date_add(
            ::Sequel::CURRENT_TIMESTAMP,
            interval.seconds
          )
        )
      end

      private

      def convert_json_fields(value)
        case value
        when ::Sequel::Postgres::JSONBArray, ::Sequel::Postgres::JSONArray
          then value.to_a
        when ::Sequel::Postgres::JSONBHash, ::Sequel::Postgres::JSONHash
          then value.to_h
        else value
        end
      end
    end
  end
end

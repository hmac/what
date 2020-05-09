# frozen_string_literal: true

require "active_record"
require "active_support/core_ext/integer"

module What
  module Connection
    # A connection adapter for ActiveRecord
    class ActiveRecord
      def initialize(connection)
        @connection = connection
      end

      def transaction(&blk)
        @connection.transaction(requires_new: true, &blk)
      end

      def execute_literal(sql)
        execute(sql).to_a
      end

      # @param queues [Array<String>]
      # @return [Hash, nil]
      def get_job(queues)
        queues_sql = "(#{queues.map { |q| @connection.quote(q) }.join(',')})"
        query = <<~SQL
          SELECT *
          FROM what_jobs
          WHERE runnable = true
          AND queue IN #{queues_sql}
          AND run_at < now()
          FOR UPDATE SKIP LOCKED
          LIMIT 1
        SQL
        job = execute(query).to_a.first
        return if job.nil?

        job.merge("args" => JSON.parse(job["args"])).symbolize_keys
      end

      def destroy_job(id)
        query = <<~SQL
          DELETE
          FROM what_jobs
          WHERE id = :id
        SQL
        execute(query, id: id)
        nil
      end

      def enqueue(job_class:, args:, queue:, run_at:)
        query =
          if run_at.nil?
            <<~SQL
              INSERT INTO what_jobs
              (job_class, args, queue, run_at, runnable)
              VALUES (:job_class, :args, :queue, NOW(), true)
            SQL
          else
            <<~SQL
              INSERT INTO what_jobs
              (job_class, args, queue, run_at, runnable)
              VALUES (:job_class, :args, :queue, :run_at, true)
            SQL
          end
        execute(
          query,
          job_class: job_class,
          args: JSON.generate(args),
          queue: queue,
          run_at: run_at
        )
      end

      def mark_as_failed(id:, last_error:)
        query = <<~SQL
          UPDATE what_jobs
          SET runnable = false,
              failed_at = now(),
              last_error = :last_error,
              error_count = error_count + 1
          WHERE id = :id
        SQL
        execute(query, id: id, last_error: last_error)
      end

      def retry_at_interval(id:, last_error:, interval:)
        interval = "#{interval.seconds} seconds"
        query = <<~SQL
          UPDATE what_jobs
          SET runnable = true,
              failed_at = now(),
              last_error = :last_error,
              error_count = error_count + 1,
              run_at = now() + :interval
          WHERE id = :id
        SQL
        execute(query, id: id, last_error: last_error, interval: interval)
      end

      private

      def execute(query, binds = {})
        @connection.exec_query(
          ::ActiveRecord::Base.sanitize_sql_array([query, binds]),
          caller_locations(1..1).first.base_label
        )
      end
    end
  end
end

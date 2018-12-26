# frozen_string_literal: true

module What
  module Failure
    # A failure strategy which retries the job at a set of intervals
    # if it failed with a particular exception.
    # This is useful for automatically handling network timeouts or other
    # transient failures.
    module VariableRetry
      RETRY_AT_INTERVAL = <<~SQL
        UPDATE what_jobs
        SET runnable = true,
            failed_at = now(),
            last_error = $2,
            error_count = error_count + 1,
            run_at = now() + $3
        WHERE id = $1
      SQL

      # rubocop:disable Metrics/MethodLength
      def handle_failure(job, error)
        error_count = job["error_count"]
        unless retryable_exception?(error) &&
               error_count < retry_intervals.length
          return NoRetry.handle_failure(job, error)
        end

        next_interval = retry_intervals[error_count]
        What.connection.execute(
          RETRY_AT_INTERVAL,
          id: job["id"],
          last_error: What::Job.format_error(error),
          interval: next_interval.to_i
        )
      end
      # rubocop:enable Metrics/MethodLength

      def retryable_exception?(exception)
        retryable_exceptions.include?(exception.class)
      end

      attr_accessor :retryable_exceptions, :retry_intervals
    end
  end
end

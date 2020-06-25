# frozen_string_literal: true

module What
  module Failure
    # A failure strategy which retries the job at a set of intervals
    # if it failed with a particular exception.
    # This is useful for automatically handling network timeouts or other
    # transient failures.
    module VariableRetry
      # rubocop:disable Metrics/AbcSize
      def handle_failure(connection, job, error)
        error_count = job[:error_count].to_i
        unless retryable_exception?(error)
          What.log_info("Exception not retryable (#{job[:id]}): #{error}")
          return NoRetry.handle_failure(connection, job, error)
        end

        if error_count >= retry_intervals.length
          What.log_info("Retry intervals exceeded (#{job[:id]})")
          return NoRetry.handle_failure(connection, job, error)
        end

        next_interval = retry_intervals[error_count]
        connection.retry_at_interval(
          id: job[:id],
          last_error: What::Job.format_error(error),
          interval: next_interval.to_i
        )
      end
      # rubocop:enable Metrics/AbcSize

      def retryable_exception?(exception)
        retryable_exceptions.include?(exception.class)
      end

      attr_accessor :retryable_exceptions, :retry_intervals
    end
  end
end

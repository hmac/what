# frozen_string_literal: true

module What
  module Failure
    # A failure strategy which permits a job to be run only once.
    # Once it has failed, it must be manually re-run or destroyed.
    module NoRetry
      MARK_AS_FAILED = <<~SQL
        UPDATE what_jobs
        SET runnable = false,
            failed_at = now(),
            last_error = $2,
            error_count = error_count + 1
        WHERE id = $1
      SQL

      def handle_failure(job, error)
        Connection.execute(
          MARK_AS_FAILED,
          id: job["id"],
          last_error: What::Job.format_error(error)
        )
      end
      module_function :handle_failure
      public :handle_failure
    end
  end
end

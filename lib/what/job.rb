# frozen_string_literal: true

require "json"

module What
  # The base class for What jobs
  # All jobs should inherit from this class
  class Job
    ENQUEUE = <<~SQL
      INSERT INTO what_jobs
      (job_class, args, queue)
      VALUES ($1, $2, $3)
    SQL
    ENQUEUE_WITH_RUN_AT = <<~SQL
      INSERT INTO what_jobs
      (job_class, args, queue, run_at)
      VALUES ($1, $2, $3, $4)
    SQL

    class << self
      def enqueue(*args, run_at: nil)
        sql = run_at ? ENQUEUE_WITH_RUN_AT : ENQUEUE
        params = { name: name, args: JSON.dump(args), queue: queue }
        params[:run_at] = run_at if run_at

        What::Connection.execute(sql, params)
      end

      def handle_failure(_job, _error)
        raise NotImplementedError
      end

      def format_error(error)
        "#{error.class}: #{error.message}\n#{error.backtrace.join("\n")}"
      end

      attr_writer :queue

      def queue
        @queue || "default"
      end
    end
  end
end

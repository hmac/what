# frozen_string_literal: true

require "json"

module What
  # The base class for What jobs
  # All jobs should inherit from this class
  class Job
    class << self
      def enqueue(*args, run_at: nil)
        What.connection.enqueue(
          job_class: name,
          args: args,
          queue: queue,
          run_at: run_at
        )
      end

      def handle_failure(_connection, _job, _error)
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

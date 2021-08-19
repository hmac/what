# frozen_string_literal: true

module ActiveJob
  module QueueAdapters
    # ActiveJob adapter
    class WhatAdapter
      def enqueue(job) # :nodoc:
        data = job.serialize
        What.connection.enqueue(
          job_class: WhatJobWrapper,
          args: [data],
          queue: data["queue_name"],
          run_at: Time.now
        )
      end

      def enqueue_at(job, timestamp) # :nodoc:
        data = job.serialize
        What.connection.enqueue(
          job_class: WhatJobWrapper,
          args: [data],
          queue: data["queue_name"],
          run_at: timestamp
        )
      end

      # This class wraps the actual job class because ActiveJob classes don't
      # inherit from What::Job.
      class WhatJobWrapper < What::Job
        def run(opts)
          klass = self.class.const_get(opts["job_class"])
          job = klass.new
          job.deserialize(opts)
          job.perform_now
        end

        def self.handle_failure(connection, job, error)
          connection.mark_as_failed(
            id: job[:id],
            last_error: What::Job.format_error(error)
          )
        end
      end
    end
  end
end

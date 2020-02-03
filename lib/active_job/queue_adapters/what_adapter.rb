# frozen_string_literal: true

module ActiveJob
  module QueueAdapters
    # ActiveJob adapter
    class WhatAdapter
      def enqueue(job) #:nodoc:
        What.connection.enqueue(
          job_class: job.class,
          args: job.serialize_arguments,
          queue: job.queue_name,
          run_at: Time.now
        )
      end

      def enqueue_at(job, timestamp) #:nodoc:
        What.connection.enqueue(
          job_class: job.class,
          args: job.serialize_arguments,
          queue: job.queue_name,
          run_at: timestamp
        )
      end
    end
  end
end

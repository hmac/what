# frozen_string_literal: true

module What
  # The What worker
  # This class is responsible for pulling jobs off the queue, working them,
  # and then destroying them
  class Worker
    def initialize(connection = nil)
      @connection = connection || What.connection
    end

    attr_reader :connection

    # rubocop:disable Metrics/AbcSize
    def work(queue)
      connection.transaction do
        job = connection.get_job(queue)
        return if job.nil? # there are no jobs to work

        begin
          klass = self.class.const_get(job[:job_class])
          connection.transaction { klass.new.run(*job[:args]) }
          connection.destroy_job(job[:id])
        rescue StandardError => error
          record_failure(job, error, klass)
        end
      end
      # Que adds another rescue here to ensure the worker doesn't crash if a
      # database error or something else transient occurs.  What's approach is
      # to prefer simplicity in this case - if the worker crashes, it's expected
      # that the platform you're running on will bring it back up.
    end
    # rubocop:enable Metrics/AbcSize

    def record_failure(job, error, klass)
      raise error if klass.nil?

      klass.handle_failure(connection, job, error)
    end
  end
end

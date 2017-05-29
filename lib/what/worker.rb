# frozen_string_literal: true

module What
  # The What worker
  # This class is responsible for pulling jobs off the queue, working them,
  # and then destroying them
  class Worker
    GET_JOB = <<~SQL
      SELECT *
      FROM what_jobs
      WHERE runnable = true
      AND queue = $1
      FOR UPDATE SKIP LOCKED
      LIMIT 1
    SQL

    DESTROY_JOB = <<~SQL
      DELETE
      FROM what_jobs
      WHERE id = $1
    SQL

    RECORD_FAILURE = <<~SQL
      UPDATE what_jobs
      SET runnable = FALSE,
          failed_at = now(),
          last_error = $2,
          error_count = $3
      WHERE id = $1
    SQL

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def self.work(queue)
      Connection.transaction do
        job = get_job(queue)
        return if job.nil? # there are no jobs to work
        begin
          klass = self.class.const_get(job["job_class"])
          args = JSON.parse(job["args"])
          Connection.transaction { klass.new.run(*args) }
          destroy_job(job)
        rescue => error
          record_failure(job, error)
        end
      end
    rescue => error
      # This means we couldn't reach the database or some other
      # error occurred whilst attempting to mark the job as failed
      #
      # We should log this
      raise error # for now while testing, raise
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def self.get_job(queue)
      Connection.execute(GET_JOB, queue: queue).to_hash[0]
    end

    def self.destroy_job(job)
      Connection.execute(DESTROY_JOB, id: job["id"])
    end

    def self.record_failure(job, error)
      formatted_error =
        "#{error.class}: #{error.message}\n#{error.backtrace.join("\n")}"
      Connection.execute(
        RECORD_FAILURE,
        id: job["id"],
        last_error: formatted_error,
        error_count: job["error_count"] + 1
      )
    end
  end
end

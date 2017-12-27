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
      AND run_at < now()
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
        rescue StandardError => error
          record_failure(job, error, klass)
        end
      end
    rescue StandardError => error
      # This means we couldn't reach the database or some other
      # error occurred whilst attempting to mark the job as failed

      What.log_error(error.message)
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def self.get_job(queue)
      Connection.execute(GET_JOB, queue: queue).to_hash[0]
    end

    def self.destroy_job(job)
      Connection.execute(DESTROY_JOB, id: job["id"])
    end

    def self.record_failure(job, error, klass)
      klass.handle_failure(job, error)
    end
  end
end

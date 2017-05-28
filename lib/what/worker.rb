# frozen_string_literal: true

module What
  class Worker
    GET_JOB = <<~SQL
      SELECT id, job_class, args
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
          last_error = $2
      WHERE id = $1
    SQL

    def self.work(queue)
      Connection.transaction do
        begin
          id, job, args = get_job(queue)
          Connection.transaction { job.run(*args) }
          destroy_job(id)
        rescue => error
          record_failure(id, error)
        end
      end
    rescue => _error
      # This means we couldn't reach the database or some other
      # error occurred whilst attempting to mark the job as failed
      #
      # We should log this
    end

    def self.get_job(queue)
      id, klass, args = Connection.execute(GET_JOB, [queue]).values.first
      [id, self.class.const_get(klass).new, args]
    end

    def self.destroy_job(id)
      Connection.execute(DESTROY_JOB, [id])
    end

    def self.record_failure(id, error)
      Connection.execute(RECORD_FAILURE, [id, error.to_s])
    end
  end
end

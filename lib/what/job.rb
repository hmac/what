# frozen_string_literal: true

module What
  class Job
    ENQUEUE = <<~SQL
      INSERT INTO what_jobs
      (job_class, args, queue)
      VALUES ($1, $2, $3)
    SQL

    def self.enqueue(*args)
      What::Connection.execute(ENQUEUE, [name, args.to_json, "default"])
    end
  end
end

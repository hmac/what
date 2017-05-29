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

    def self.enqueue(*args)
      What::Connection.execute(
        ENQUEUE,
        name: name, args: JSON.dump(args), queue: "default"
      )
    end
  end
end

# frozen_string_literal: true

require "what/connection"

class JobStats
  class Job
    def initialize(job_class:, args:, last_error:, **_args)
      @job_class = job_class
      @args = args
      @last_error = last_error
    end

    attr_reader :job_class, :args, :last_error
  end

  def self.count
    What::Connection.execute("SELECT COUNT(*) FROM what_jobs").values[0][0]
  end

  def self.first
    job = What::Connection.execute("SELECT * FROM what_jobs LIMIT 1").hash
    puts job
    Job.new(**job)
  end
end

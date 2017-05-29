What
====

Que, but for Rails 5+ and Postgres 9.5+.

Table Structure
---------------

    CREATE TABLE what_jobs (
      id serial,
      job_class text,
      args json,
      queue text,
      run_at timestamp,
      failed_at timestamp,
      last_error text,
      error_count integer,
      runnable boolean
    )

Usage
-----

## 1. Add What to your Gemfile

    # This will be less ridiculous once What is released/is on rubygems
    gem "what", git: "https://github.com/hmac/what"

## 2. Create an entrypoint file for your project.
This is the file that What workers will load before running your jobs - it
should require all the relevant classes and libraries necessary for your jobs
to run. For Rails, you should be able to use `config/environment.rb` instead
of creating your own. For an example, see `spec/support.rb`.

## 3. Write your jobs as subclasses of `What::Job`
Your jobs should subclass `What::Job` and define a `run` method which will be
called by the worker.

    class ResetUserPassword < What::Job
      def run(id)
        user = User.find(id)
        ResetPasswordMailer.new(user).deliver!
      end
    end

## 4. Spin up What workers
What workers run in separate processes, and can be launched via the `what`
executable. They take as arguments the queue to work and the entrypoint file.

    bundle exec what default ./entrypoint.rb

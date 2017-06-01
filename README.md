What
====

Que, but for Rails 5+ and Postgres 9.5+.

[![CircleCI](https://circleci.com/gh/hmac/what.svg?style=svg)](https://circleci.com/gh/hmac/what)

Table Structure
---------------

```sql
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
```

Usage
-----

## 1. Add What to your Gemfile

```ruby
    # This will be less ridiculous once What is released/is on rubygems
    gem "what", git: "https://github.com/hmac/what"
```

## 2. Create an entrypoint file for your project.
This is the file that What workers will load before running your jobs - it
should require all the relevant classes and libraries necessary for your jobs
to run. For Rails, you should be able to use `config/environment.rb` instead
of creating your own. For an example, see `spec/support.rb`.

## 3. Write your jobs as subclasses of `What::Job`
Your jobs should subclass `What::Job` and define a `run` method which will be
called by the worker. You should also specify a failure strategy (see below for
more information on failure strategies), although if you don't then `NoRetry`
will be used by default. You can also specify a queue, which defaults to
"default".

```ruby
    class ResetUserPassword < What::Job
      extend What::Failure::NoRetry

      self.queue = "emails"

      def run(id)
        user = User.find(id)
        ResetPasswordMailer.new(user).deliver!
      end
    end
```

## 4. Spin up What workers
What workers run in separate processes, and can be launched via the `what`
executable. They take as arguments the queue to work and the entrypoint file.

    bundle exec what default ./entrypoint.rb

Working Jobs
------------

What works jobs in the following way:

1. Scan the `what_jobs` table for a qualifying job (runnable, in the right queue etc.)
2. If that job is locked by another process, skip it and go to the next one.
3. When a qualifying, unlocked job is found, take a FOR UPDATE lock on it.
4. Instantiate the `job_class` and call its `run` method with the stored arguments.
5. If `run` raises no exceptions, destroy the job.
6. If `run` raises an exception, call the `handle_failure` method of the class.

Steps 1-3 happen atomically via PostgreSQL's `FOR UPDATE SKIP LOCKED` clause
(see [here](https://www.postgresql.org/docs/9.5/static/sql-select.html#SQL-FOR-UPDATE-SHARE) for more info).

If the job fails, it is typically left in the queue. It might be rescheduled to run again
or left to be handled manually. This behaviour is governed by the failure strategy (see below).

Queues
------

What supports multiple queues, which are effectively labels that are applied
to jobs. A job class can specify its queue using the class-level attribute
writer inherited from `What::Job`.

```ruby
    class MyJob
      self.queue = "my_custom_queue"
      ...
    end
```

What workers are given a single specific queue to work on, which is specified
at startup, so you'll probably want at least one worker process for each
queue you use.

Failure Strategies
------------------

What provides several ways for dealing with job failure. These are defined as
failure strategies, and can be configured on a per-job basis. To use a
particular strategy, set it in your job class by `extend`ing the strategy
(they're modules).

```ruby
    class MyJob
      extend What::Failure::NoRetry
      ...
    end
```

The details of the different failure strategies are outlined below.

## `NoRetry`

`NoRetry` is for jobs which shouldn't automatically retried. On failure, the
job will be left in the queue. The following attributes will be set:

- `runnable: false` - this means the job won't get picked up by any worker
- `failed_at: [timestamp]` - the time that the job failed
- `last_error: [string]` - the exception and backtrace that caused the failure

To handle a failed job under `NoRetry`, you'll need to either manually
reschedule it (by updating `runnable` to `true`) or destroy it.

## `VariableRetry`

`VariableRetry` is for jobs which can be retried under certain conditions. It
is configured with two class-level attributes: `retryable_exceptions` and
`retry_intervals`.

```ruby
    class MyJob
      extend What::Failure::VariableRetry

      self.retryable_exceptions = [AnError, AnotherError]
      self.retry_intervals = [5, 30, 60]
      ...
    end
```

`retryable_exceptions` defines a list of exceptions for which this job can be
retried. If the job fails due to one of these exceptions, it will be
rescheduled to run at a certain point in the future, defined by
`retry_intervals`.

`retry_intervals` defines a list of intervals, in seconds, at which this
job will be rescheduled if it fails (with a retryable exception).
The first interval will be used after the first failure, the second after a
second failure, and so on. If the intervals are exhausted, the job falls back
to `NoRetry` behaviour and will not be rescheduled.

As an example, take the job above. If it fails with `AnError`, it will be
rescheduled to run in 5 seconds time. If it fails again with `AnError`, it will
be rescheduled to run in 30 seconds time. If it fails again with `AnotherError`,
it will be rescheduled to run in 60 seconds time. If it fails again, it will
not be rescheduled.

What jobs use the `error_count` column to keep track of the number of failures
they have had. The `last_error` column will only show the most recent error, and
is intended for diagnostic purposes.

References
----------

What is a shameless rip-off of [Que](https://github.com/chanks/que).

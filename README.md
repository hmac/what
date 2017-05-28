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

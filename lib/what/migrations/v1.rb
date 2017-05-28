# frozen_string_literal: true

module What
  module Migrations
    class V1 < ActiveRecord::Migration[5.0]
      def up
        execute(<<~SQL)
          CREATE TABLE what_jobs (
            id serial NOT NULL,
            job_class text NOT NULL,
            args json NOT NULL,
            queue text NOT NULL,
            run_at timestamp with time zone DEFAULT now() NOT NULL,
            failed_at timestamp with time zone,
            last_error text,
            error_count integer DEFAULT 0 NOT NULL,
            runnable boolean DEFAULT true NOT NULL
          )
        SQL
      end

      def down
        execute(<<~SQL)
          DROP TABLE what_jobs
        SQL
      end
    end
  end
end

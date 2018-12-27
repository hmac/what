# frozen_string_literal: true

module What
  module Failure
    # A failure strategy which permits a job to be run only once.
    # Once it has failed, it must be manually re-run or destroyed.
    module NoRetry
      def handle_failure(connection, job, error)
        connection.mark_as_failed(
          id: job[:id],
          last_error: What::Job.format_error(error)
        )
      end

      # rubocop:disable Style/AccessModifierDeclarations
      module_function :handle_failure
      public :handle_failure
      # rubocop:enable Style/AccessModifierDeclarations
    end
  end
end

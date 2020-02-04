# frozen_string_literal: true

require "what/version"
require "what/config"
require "what/failure/no_retry"
require "what/failure/variable_retry"
require "what/worker"
require "what/job"

# rubocop:disable Style/Documentation
module What
  class << self
    def log_info(message)
      logger&.info(message)
    end

    def log_error(message)
      logger&.error(message)
    end

    # We allow config.connection to be a Proc to support lazy connection
    # checkout. This means What will only complain about the lack of a database
    # connection if it's actually used.
    def connection
      if config.connection.is_a?(Proc)
        config.connection = config.connection.call
      end

      config.connection
    end

    def logger
      config.logger
    end

    def configure
      yield config
    end

    private

    def config
      @config ||= Config.new
    end
  end
end
# rubocop:enable Style/Documentation

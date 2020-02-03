# frozen_string_literal: true

require "what/version"
require "what/config"
require "what/failure/no_retry"
require "what/failure/variable_retry"
require "what/worker"
require "what/job"
require "what/connection"
require "what/migrations/v1"

# rubocop:disable Style/Documentation
module What
  class << self
    def log_info(message)
      logger&.info(message)
    end

    def log_error(message)
      logger&.error(message)
    end

    def connection
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

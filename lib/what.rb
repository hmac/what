# frozen_string_literal: true

require "what/version"
require "what/connection"
require "what/failure/no_retry"
require "what/failure/variable_retry"
require "what/worker"
require "what/job"

# rubocop:disable Style/Documentation
module What
  class << self
    attr_writer :logger

    def log_info(message)
      @logger&.info(message)
    end

    def log_error(message)
      @logger&.error(message)
    end
  end
end
# rubocop:enable Style/Documentation

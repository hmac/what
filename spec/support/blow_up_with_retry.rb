# frozen_string_literal: true

class BlowUpWithRetry < What::Job
  extend What::Failure::VariableRetry
  class ExplosionError < StandardError; end

  self.retryable_exceptions = [ExplosionError]
  self.retry_intervals = [3600] # 1 hour

  def run(exception = nil)
    raise exception || ExplosionError
  end
end

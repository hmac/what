# frozen_string_literal: true

class BlowUp < What::Job
  extend What::Failure::NoRetry

  def run(arg = nil)
    raise "oh noes! - #{arg}"
  end
end

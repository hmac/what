# frozen_string_literal: true

class BlowUp < What::Job
  extend What::Failure::NoRetry

  def run(i = nil)
    raise "oh noes! - #{i}"
  end
end

# frozen_string_literal: true

class BlowUp < What::Job
  def run(i = nil)
    raise "oh noes! - #{i}"
  end
end

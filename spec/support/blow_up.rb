# frozen_string_literal: true

class BlowUp < What::Job
  def run
    raise "oh noes!"
  end
end

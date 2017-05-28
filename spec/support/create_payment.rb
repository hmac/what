# frozen_string_literal: true

class CreatePayment < What::Job
  def run(amount)
    Payment.create!(amount: amount)
  end
end

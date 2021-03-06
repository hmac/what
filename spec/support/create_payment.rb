# frozen_string_literal: true

class CreatePayment < What::Job
  extend What::Failure::NoRetry

  def run(amount)
    Payment.create!(amount: amount)
  end
end

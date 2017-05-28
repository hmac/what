# frozen_string_literal: true

class Payment
  def self.count
    What::Connection.execute("SELECT COUNT(*)::int FROM payments").values[0][0]
  end

  def self.create!(amount:)
    What::Connection.execute(
      "INSERT INTO payments (amount) VALUES ($1)",
      [amount]
    )
  end
end

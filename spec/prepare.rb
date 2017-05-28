# frozen_string_literal: true

$LOAD_PATH << "lib"
require_relative "spec_helper"

What::Connection.execute("DROP TABLE IF EXISTS payments")
What::Connection.execute("CREATE TABLE payments (amount integer)")

# frozen_string_literal: true

FactoryBot.define do
  factory :login do
    name { "betfair" }
    username { ENV.fetch("BETFAIR_USER", "user") }
    password { ENV.fetch("BETFAIR_PASS", "pass") }
  end
end

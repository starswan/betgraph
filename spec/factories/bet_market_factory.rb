# frozen_string_literal: true

#
# $Id$
#
FactoryBot.define do
  MARKET_NAMES = ["Correct Score"].freeze

  factory :bet_market do
    name { MARKET_NAMES.sample }
    number_of_winners { 1 }
    number_of_runners { 1 }
    status { BetMarket::ACTIVE }
    markettype { "Market Type" }
    sequence(:marketid)
    exchange_id { 1 }
    runners_may_be_added { false }
    live { false }
    total_matched_amount { 0 }
    time { Time.now }

    trait :overunder do
      markettype { "O" }
      name { "Over/Under 2.5 goals" }
    end

    trait :closed do
      status { BetMarket::CLOSED }
    end

    trait :asian do
      markettype { "A" }
    end

    # association :match, factory: :soccer_match
  end

  factory :betfair_market_type do
    name { "Market Type" }
    valuer { "CorrectScore" }
    active { true }
    association :sport
  end
end

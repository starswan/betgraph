#
# $Id$
#
FactoryBot.define do
  factory :bet_market do
    name { "Correct Score" }
    number_of_runners { 1 }
    status { BetMarket::ACTIVE }
    markettype { "Market Type" }
    sequence(:marketid)
    exchange_id { 1 }
    live { false }
    total_matched_amount { 0 }
    time { Time.zone.now }

    trait :overunder do
      markettype { "O" }
      name { "Over/Under 2.5 goals" }
    end

    trait :open do
      status { BetMarket::OPEN }
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
    name { "Correct Score" }
    valuer { "CorrectScore" }
    active { true }
    association :sport

    trait :asian do
      name { "Asian Handicap" }
    end
  end
end

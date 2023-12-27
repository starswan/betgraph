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
    price_source { 'RestAPI'}

    trait :overunder do
      markettype { "OVER_UNDER-25" }
      name { "Over/Under 2.5 goals" }
    end

    trait :correct_score do
      markettype { "CORRECT_SCORE" }
      name { "Correct Score" }
    end

    trait :match_odds do
      markettype { "MATCH_ODDS" }
      name { "Match Odds" }
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
  end

  factory :betfair_market_type do
    name { "Correct Score" }
    valuer { "CorrectScore" }
    active { true }
    association :sport

    trait :asian do
      name { "Asian Handicap" }
    end

    trait :correct_score do
      name { "Correct Score" }
      valuer { "CorrectScore" }
    end

    trait :overunder25 do
      name { "Over/Under 2.5 goals" }
      valuer { "OverUnderGoals" }
    end

    trait :match_odds do
      name { "Match Odds" }
      valuer { "MatchOdds" }
    end
  end
end

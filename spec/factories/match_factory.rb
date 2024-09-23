# frozen_string_literal: true

#
# $Id$
#
FactoryBot.define do
  factory :match do
    name { "A v B" }
    kickofftime { Time.zone.now }

    factory :tennis_match do
      type { "TennisMatch" }
    end
  end

  factory :soccer_match do
    sequence(:name) { |n| "Team A#{n} v Team B#{n}" }
    kickofftime { Time.zone.now }
    endtime { kickofftime + 110.minutes }

    transient do
      with_runners_and_prices { false }
      with_markets_and_runners { false }
    end

    after(:create) do |model, eveluator|
      if eveluator.with_markets_and_runners
        create_list(:bet_market, 1, match: model, market_runners: build_list(:market_runner, 2))
      end

      if eveluator.with_runners_and_prices
        mpt = create(:market_price_time)
        model.bet_markets.each do |bm|
          bm.market_runners.each do |r|
            create(:price, market_runner: r, market_price_time: mpt)
          end
        end
      end
    end
  end

  factory :result do
    homescore { 0 }
    awayscore { 0 }
  end
end

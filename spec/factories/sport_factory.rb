# frozen_string_literal: true

FactoryBot.define do
  factory :sport do
    # This needs to be high enough to avoid all the fixture data
    sequence(:betfair_sports_id) { |n| n + 50 }
    name { ["Motor Sport", "Cricket", "Golf", "Tennis", "Boxing"].sample }
    active { true }

    factory :soccer do
      name { "Soccer" }
      betfair_sports_id { 1 }
    end

    factory :baseball do
      name { "Baseball" }
      betfair_sports_id { 7511 }
    end

    factory :motor_sport do
      name { "Motor Sport" }
      betfair_sports_id { 8 }
    end
  end

  factory :calendar do
    sequence(:name) { |n| "Calendar #{n}" }

    association :sport
  end

  factory :competition do
    association :division

    sequence(:name) { |n| "Competition #{n}" }
    sequence(:betfair_id)
    active { true }
    region { "GBR" }
  end
end

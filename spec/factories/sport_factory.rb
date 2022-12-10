# frozen_string_literal: true

FactoryBot.define do
  factory :sport do
    # This needs to be high enough to avoid all the fixture data
    sequence(:betfair_sports_id) { |n| n + 50 }
    sequence(:name) { |n| "Sport#{n}" }
    active { true }

    factory :soccer do
      name { "Soccer" }
    end
  end

  factory :calendar do
    sequence(:name) { |n| "Calendar #{n}" }

    association :sport
  end
end

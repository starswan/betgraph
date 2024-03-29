# frozen_string_literal: true

FactoryBot.define do
  factory :football_division do
    association :division

    trait :premier_league do
      bbc_slug { "premier-league" }
      football_data_code { "E0" }
    end

    trait :league_one do
      football_data_code { "E2" }
      bbc_slug { "league-one" }
    end
  end

  factory :division do
    sequence(:name) { |n| "League Division #{n}" }
    active { true }

    association :calendar

    trait :inactive do
      active { false }
    end

    trait :league_one_2018 do
      name { "League One" }
    end
  end
end

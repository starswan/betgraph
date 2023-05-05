# frozen_string_literal: true

FactoryBot.define do
  factory :football_division do
    association :division

    trait :premier_league do
      bbc_slug { "premier-league" }
    end
  end

  factory :division do
    name { "A Division" }
    active { true }

    association :calendar

    trait :inactive do
      active { false }
    end
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :football_division do
    association :division

    trait :premier_league do
      bbc_slug { "premier-league" }
    end
  end

  factory :division do
    sequence(:name) { |n| "League Division #{n}" }
    active { true }

    association :calendar

    trait :inactive do
      active { false }
    end
  end
end

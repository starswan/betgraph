# frozen_string_literal: true

FactoryBot.define do
  factory :season do
    association :calendar

    trait :first do
      startdate { Date.today - 20.years }
    end
    trait :final do
      startdate { Date.today + 10.years }
    end
    name { "A Season" }
    startdate { Date.today - 1.year }
  end
end

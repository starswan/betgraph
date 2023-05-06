# frozen_string_literal: true

FactoryBot.define do
  factory :season do
    association :calendar

    trait :first do
      startdate { Date.today - 30.years }
    end
    trait :final do
      startdate { Date.today + 20.years }
    end

    sequence(:startdate) { |n| Date.today - 29.years + n.years }
    name { "Season from #{startdate}" }
  end
end

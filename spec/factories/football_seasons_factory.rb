# frozen_string_literal: true

FactoryBot.define do
  factory :season do
    association :calendar

    trait :first do
      startdate { Time.zone.today - 30.years }
    end
    trait :final do
      startdate { Time.zone.today + 20.years }
    end

    sequence(:startdate) { |n| Time.zone.today - 29.years + n.years }
    name { "Season from #{startdate}" }
  end
end

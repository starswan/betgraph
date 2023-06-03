# frozen_string_literal: true

FactoryBot.define do
  factory :season do
    association :calendar

    trait :first do
      startdate { Time.zone.today.beginning_of_year - 5.months - 30.years }
    end
    trait :final do
      startdate { Time.zone.today.beginning_of_year - 5.months + 20.years }
    end

    sequence(:startdate) { |n| Time.zone.today.beginning_of_year - 5.months - 30.years + n.years }
    name { "#{startdate.year}/#{startdate.year + 1}" }
  end
end

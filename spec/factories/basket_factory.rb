# frozen_string_literal: true

FactoryBot.define do
  factory :basket_rule do
    name { "Thing" }
    association :sport
  end

  factory :basket do
    missing_items_count { 4 }
    association :basket_rule
  end

  factory :basket_item do
    association :market_runner
    weighting { 1 }
  end

  factory :basket_rule_item do
    weighting { 1 }
  end
end

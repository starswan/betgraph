# frozen_string_literal: true

FactoryBot.define do
  factory :menu_path do
    sequence(:name) { |n| ["Menu Path#{n}"] }
    active { true }

    association :sport
  end
end

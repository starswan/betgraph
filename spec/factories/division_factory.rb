# frozen_string_literal: true

FactoryBot.define do
  factory :football_division do
    association :division
  end

  factory :division do
    name { "A Division" }

    association :calendar
  end
end

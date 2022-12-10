# frozen_string_literal: true

FactoryBot.define do
  factory :betfair_runner_type do
    sequence(:name) { |x| "Runner Type Name #{x}" }
    sequence(:runnertype) { |x| "Runner Type#{x}" }
    runnerhomevalue { 0 }
    runnerawayvalue { 0 }

    association :betfair_market_type
  end

  factory :market_runner do
    sequence(:description) { |n| "Runner #{n}" }
    sequence(:selectionId)
    asianLineId { 0 }
  end

  factory :trade do
    size { 1 }
    price { 1.4 }
    side { "B" }
  end
end

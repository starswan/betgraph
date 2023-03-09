# frozen_string_literal: true

FactoryBot.define do
  factory :market_price_time do
    # This generates the expected flow of midnight, midnight + 1 second etc...
    sequence(:time) { |seq| Time.zone.yesterday + seq.seconds }
  end

  # factory :market_price do
  #   status { MarketPrice::ACTIVE }
  #   back1price { 1.5 }
  #   back1amount { 10.0 }
  #
  #   trait :good_lay_price do
  #     lay1price { 2.5 }
  #     lay1amount { 10.0 }
  #   end
  # end
  factory :price do
    price { 1.5 }
    side { "B" }
    amount { 10.0 }
    depth { 1 }

    trait :good_lay_price do
      price { 2.5 }
      amount { 10.0 }
      side { "L" }
      depth { 1 }
    end
  end
end

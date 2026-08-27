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
    back_price { 1.5 }
    back_amount { 10.0 }
    depth { 1 }

    # trait :back do
    #   side { "B" }
    # end
    #
    # trait :lay do
    #   side { "L" }
    # end

    trait :good_lay_price do
      lay_price { 2.5 }
      lay_amount { 10.0 }
      depth { 1 }
    end
  end
end

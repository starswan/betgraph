# frozen_string_literal: true

class PriceGroup
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :bet_market, :market_prices, :time

  validate :check_overrounds, unless: -> { bet_market.asian_handicap? }

private

  def check_overrounds
    market_overround = market_prices.select(&:active?).map { |market_price|
      market_price.back_price_set.probability
    }.sum
    errors.add(:market_prices, "overround too high #{market_overround}") if market_overround > 1.8
    errors.add(:market_prices, "overround too low #{market_overround}") if market_overround < 0.5
  end
end

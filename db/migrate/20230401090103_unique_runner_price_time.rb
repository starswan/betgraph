# frozen_string_literal: true

class UniqueRunnerPriceTime < ActiveRecord::Migration[6.1]
  def change
    MarketPriceTime
      .includes(:market_prices)
      .find_each.reject { |mpt| mpt.market_prices.uniq(&:market_runner_id).size == mpt.market_prices.size }
                   .each(&:destroy)
    add_index :market_prices, [:market_price_time_id, :market_runner_id], unique: true
  end
end

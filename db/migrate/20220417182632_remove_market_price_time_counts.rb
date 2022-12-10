# frozen_string_literal: true

class RemoveMarketPriceTimeCounts < ActiveRecord::Migration[6.0]
  def change
    remove_reference :market_price_times, :bet_market
    rename_column :bet_markets, :market_price_times_count, :market_prices_count
    rename_column :matches, :market_price_times_count, :market_prices_count
  end
end

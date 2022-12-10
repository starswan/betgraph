# frozen_string_literal: true

class ResetMarketPriceCounters < ActiveRecord::Migration[6.0]
  def up
    MarketPrice.counter_culture_fix_counts
  end
end

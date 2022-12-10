# frozen_string_literal: true

#
# $Id$
#
class AddMarketPriceTimesCountToMatches < ActiveRecord::Migration[5.1]
  def self.up
    add_column :matches, :market_price_times_count, :integer, null: false, default: 0
    MarketPriceTime.counter_culture_fix_counts
  end

  def self.down
    remove_column :matches, :market_price_times_count
  end
end

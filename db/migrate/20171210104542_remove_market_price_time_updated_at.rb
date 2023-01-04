# frozen_string_literal: true

#
# $Id$
#
class RemoveMarketPriceTimeUpdatedAt < ActiveRecord::Migration[4.2]
  BATCH_SIZE = 100000
  def up
    remove_column :market_price_times, :updated_at
    remove_column :market_prices, :updated_at
    remove_column :market_prices, :created_at

    count = MarketPrice.count
    index = 0
    MarketPrice.includes(:market_price_time).find_in_batches(batch_size: BATCH_SIZE) do |batch|
      say_with_time("#{Time.zone.now} checking MarketPrice #{index}/#{count} #{100.0 * index / count}%") do
        batch.each { |mp| mp.destroy unless mp.market_price_time }
      end
      index += BATCH_SIZE
    end

    add_foreign_key :market_prices, :market_price_times
  end

  def down
    remove_foreign_key :market_prices, :market_price_times

    add_column :market_prices, :created_at, :timestamp
    add_column :market_prices, :updated_at, :timestamp
    add_column :market_price_times, :updated_at, :timestamp
  end
end

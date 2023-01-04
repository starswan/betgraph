# frozen_string_literal: true

#
# $Id$
#
class AddPricesCounterCache < ActiveRecord::Migration[5.1]
  BATCH_SIZE = 5000

  def up
    change_table :market_price_times do |t|
      t.integer :market_prices_count, null: false, default: 0
    end

    index, count = 0, MarketPriceTime.count

    MarketPriceTime.includes(:market_prices).find_in_batches(batch_size: BATCH_SIZE) do |batch|
      percentage = sprintf("%.2f", (100.0 * index / count))
      say_with_time("#{Time.zone.now} changing MarketPriceTime #{index}/#{count} #{percentage}%") do
        MarketPriceTime.transaction do
          batch.each do |mpt|
            # This turns out to be the fastest implementation - generates direct SQL w/o the overhead of reset_counters
            MarketPriceTime.update_counters mpt.id, market_prices_count: mpt.market_prices.size
          end
        end
      end
      index += BATCH_SIZE
    end
  end

  def down
    remove_column :market_price_times, :market_prices_count
  end
end

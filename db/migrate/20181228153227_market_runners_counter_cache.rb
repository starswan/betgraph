# frozen_string_literal: true

#
# $Id$
#
class MarketRunnersCounterCache < ActiveRecord::Migration[5.1]
  BATCH_SIZE = 3000

  def up
    add_column :bet_markets, :market_runners_count, :integer, null: false, default: 0

    count = BetMarket.count
    index = 0
    BetMarket.includes(:market_runners).find_in_batches(batch_size: BATCH_SIZE) do |batch|
      percentage = "%.2f" % (100.0 * index / count)
      say_with_time("#{Time.now} changing BetMarket #{index}/#{count} #{percentage}%") do
        batch.each do |bm|
          # bm.update(market_price_times_count: bm.market_price_times.size)
          # BetMarket.reset_counters bm.id, :market_price_times
          # This turns out to be the fastest implementation - generates direct SQL w/o the overhead of reset_counters
          BetMarket.update_counters bm.id, market_runners_count: bm.market_runners.size
        end
      end
      index += BATCH_SIZE
    end
  end

  def down
    remove_column :bet_markets, :market_runners_count
  end
end

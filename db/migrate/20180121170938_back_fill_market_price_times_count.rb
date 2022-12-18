# frozen_string_literal: true

#
# $Id$
#
class BackFillMarketPriceTimesCount < ActiveRecord::Migration[4.2]
  BATCH_SIZE = 300

  def up
    count = BetMarket.count
    index = 0
    done = 0
    BetMarket.includes(:market_price_times).find_in_batches(batch_size: BATCH_SIZE) do |batch|
      percentage = sprintf("%.2f", (100.0 * index / count))
      say_with_time("#{Time.zone.now} #{done} changing BetMarket #{index}/#{count} #{percentage}%") do
        batch.select { |bm| bm.market_price_times_count != bm.market_price_times.size }.each do |bm|
          # bm.update(market_price_times_count: bm.market_price_times.size)
          # BetMarket.reset_counters bm.id, :market_price_times
          # This turns out to be the fastest implementation - generates direct SQL w/o the overhead of reset_counters
          BetMarket.update_counters bm.id, market_price_times_count: bm.market_price_times.size - bm.market_price_times_count
          done += 1
        end
      end
      index += BATCH_SIZE
    end
    say("Completed modified #{done} records")
  end
end

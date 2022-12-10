# frozen_string_literal: true

class ConsolidateMarketPriceTimesOnMatches < ActiveRecord::Migration[6.0]
  BATCH_SIZE = 100
  MPT_BATCH_SIZE = 1000

  def up
    # there are no MPT's with a zero market_prices_count
    market_price_times = MarketPriceTime.where.not(market_prices_count: 0)
    batches = Enumerator.new { |yielder|
      batch = []
      list = []
      market_price_times.find_each(batch_size: MPT_BATCH_SIZE) do |mpt|
        if list.empty? || (list.last.time == mpt.time)
          list << mpt
        else
          batch << list
          list = []
          if batch.size == BATCH_SIZE
            yielder << batch
            batch = []
          end
        end
      end
      yielder << batch unless batch.empty?
    }.lazy

    count = market_price_times.select(:time).distinct.count / BATCH_SIZE
    batches.each_with_index do |batch, index|
      say_with_time "MarketPriceTime consolidation #{MarketPriceTime.count} batch #{index} of #{count}" do
        Match.transaction do
          batch.each do |event_list|
            event_list[1..].each do |event|
              event.market_prices.each { |p| event_list[0].market_prices << p }
              event.delete
            end
          end
        end
      end
    end
  end
end

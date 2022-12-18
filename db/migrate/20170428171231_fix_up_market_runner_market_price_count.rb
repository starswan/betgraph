# frozen_string_literal: true

#
# $Id$
#
class FixUpMarketRunnerMarketPriceCount < ActiveRecord::Migration[4.2]
  BATCH_SIZE = 1000
  def up
    ActiveRecord::Base.connection.execute <<-SQL.squish
      UPDATE market_runners
      SET market_prices_count = (SELECT count(1)
                               FROM market_prices
                              WHERE market_prices.market_runner_id = market_runners.id)
    SQL
  end

  def rails_up
    count = MarketRunner.count
    start_time = Time.zone.now
    index = 0
    MarketRunner.find_in_batches(batch_size: BATCH_SIZE) do |mrbatch|
      run_time = Time.zone.now - start_time
      est_run_time = run_time * count / (index + 10)
      finish = start_time + est_run_time
      say_with_time "#{index}/#{count} est. finish #{finish}" do
        mrbatch.each do |mr|
          MarketRunner.reset_counters(mr.id, :market_prices)
        end
      end
      index += BATCH_SIZE
    end
  end
end

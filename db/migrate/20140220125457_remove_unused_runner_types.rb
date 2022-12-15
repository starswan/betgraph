# frozen_string_literal: true

#
# $Id$
#
class RemoveUnusedRunnerTypes < ActiveRecord::Migration[4.2]
  BATCH_SIZE = 10000

  def up
    count, index = BetfairMarketType.count, 0
    BetfairMarketType.find_each do |market_type|
      if market_type.bet_markets.count == 0
        say_with_time "#{index}/#{count} Deleting unused Market Type #{market_type.sport.name} #{market_type.name}" do
          market_type.destroy
        end
      end
      index += 1
    end
    count, index = BetfairRunnerType.count, 0
    BetfairRunnerType.find_in_batches(batch_size: BATCH_SIZE) do |rt_group|
      rt_group.each do |runner_type|
        if runner_type.market_runners.count == 0
          say_with_time "#{index}/#{count} Deleting #{runner_type.betfair_market_type.sport.name} #{runner_type.betfair_market_type.name} - #{runner_type.name}" do
            runner_type.destroy
          end
        end
        index += 1
      end
    end
  end

  def down; end
end

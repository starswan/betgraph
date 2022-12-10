# frozen_string_literal: true

#
# $Id$
#
class RemoveUnusedRunnerTypes < ActiveRecord::Migration[4.2]
  BATCH_SIZE = 10000

  def up
    count, index = BetfairMarketType.count, 0
    BetfairMarketType.find_each do |marketType|
      if marketType.bet_markets.count == 0
        say_with_time "#{index}/#{count} Deleting unused Market Type #{marketType.sport.name} #{marketType.name}" do
          marketType.destroy
        end
      end
      index += 1
    end
    count, index = BetfairRunnerType.count, 0
    BetfairRunnerType.find_in_batches(batch_size: BATCH_SIZE) do |rt_group|
      rt_group.each do |runnerType|
        if runnerType.market_runners.count == 0
          say_with_time "#{index}/#{count} Deleting #{runnerType.betfair_market_type.sport.name} #{runnerType.betfair_market_type.name} - #{runnerType.name}" do
            runnerType.destroy
          end
        end
        index += 1
      end
    end
  end

  def down; end
end

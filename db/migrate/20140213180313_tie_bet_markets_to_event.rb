# frozen_string_literal: true

#
# $Id$
#
class TieBetMarketsToEvent < ActiveRecord::Migration[4.2]
  BATCH_SIZE = 20000
  def up
    index = 0
    count = BetMarket.count
    BetMarket.find_in_batches(batch_size: BATCH_SIZE, include: :betfair_event) do |bm_group|
      say_with_time "#{self} BetMarkets #{index}/#{count} #{100 * index / count}%" do
        bm_group.each do |bm|
          destroy(index, count, bm) unless bm.betfair_event
        end
      end
      index += BATCH_SIZE
    end
    add_foreign_key :bet_markets, :betfair_events
  end

  def down
    remove_foreign_key :bet_markets, :betfair_events
  end

private

  def destroy(index, count, market)
    say_with_time "#{index}/#{count} Destroying #{market.menu_path_name[-1]} #{market.time} #{market.name}" do
      market.destroy
    end
  end
end

# frozen_string_literal: true

#
# $Id$
#
class AddLivePricedToBetMarket < ActiveRecord::Migration[4.2]
  BATCH_SIZE = 5000
  def up
    # remove_column :bet_markets, :live_priced
    change_table :bet_markets do |t|
      t.boolean :live_priced, null: false, default: false
    end
    # This is the correct thing to do, but the runtime appears to be > 3hours so it hardly seems worth it...
    #
    # index, count = 0, BetMarket.count
    # BetMarket.find_in_batches(batch_size: BATCH_SIZE, :include => :betfair_event) do |bm_group|
    #  say_with_time "#{self} BetMarkets #{index}/#{count} #{100*index/count}%" do
    #    bm_group.each do |bm|
    #      bm.live_priced = bm.betfair_event.live_priced
    #      bm.save!
    #    end
    #  end
    #  index += BATCH_SIZE
    # end
  end

  def down
    remove_column :bet_markets, :live_priced
  end
end

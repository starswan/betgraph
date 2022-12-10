# frozen_string_literal: true

#
# $Id$
#
class AddPriceTimesCountToMarket < ActiveRecord::Migration[4.2]
  BATCH_SIZE = 200

  def change
    change_table :bet_markets do |t|
      t.integer :market_price_times_count, null: false, default: 0
    end
  end
end

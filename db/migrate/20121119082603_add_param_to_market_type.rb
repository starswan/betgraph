# frozen_string_literal: true

#
# $Id$
#
class AddParamToMarketType < ActiveRecord::Migration[4.2]
  def up
    change_table :betfair_market_types do |t|
      t.decimal :param1, null: false, default: 0, precision: 5, scale: 2
    end
    count = BetfairMarketType.count
    BetfairMarketType.all.each_with_index do |bmt, index|
      say_with_time "#{bmt.name} #{index}/#{count}" do
        bmt.betfair_runner_types.each do |brt|
          if brt.runnerhomevalue > 0
            bmt.param1 = brt.runnerhomevalue
            bmt.save!
            break
          end
        end
      end
    end
  end

  def down
    remove_column :betfair_market_types, :param1
  end
end

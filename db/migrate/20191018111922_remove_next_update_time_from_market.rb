# frozen_string_literal: true

#
# $Id$
#
class RemoveNextUpdateTimeFromMarket < ActiveRecord::Migration[5.1]
  def up
    remove_column :bet_markets, :nextUpdateTime
  end

  def down
    add_column :bet_markets, :nextUpdateTime, :datetime, null: false, default: Time.zone.now
    change_column_default :bet_markets, :nextUpdateTime, nil
  end
end

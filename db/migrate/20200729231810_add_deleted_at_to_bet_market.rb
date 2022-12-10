# frozen_string_literal: true

#
# $Id$
#
class AddDeletedAtToBetMarket < ActiveRecord::Migration[5.1]
  def change
    add_column :bet_markets, :deleted_at, :datetime
    add_index :bet_markets, :deleted_at
    remove_column :bet_markets, :deleted
  end
end

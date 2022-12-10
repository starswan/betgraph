# frozen_string_literal: true

#
# $Id$
#
class AddDeletedFlagToBetMarket < ActiveRecord::Migration[4.2]
  def change
    change_table :bet_markets do |t|
      t.boolean :deleted, null: false, default: false
    end
  end
end

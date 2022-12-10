# frozen_string_literal: true

#
# $Id$
#
class ExpandBetMarketType < ActiveRecord::Migration[4.2]
  def up
    change_column :bet_markets, :markettype, :string, limit: 20, null: false
  end

  def down
    change_column :bet_markets, :markettype, :string, limit: 1, null: false
  end
end

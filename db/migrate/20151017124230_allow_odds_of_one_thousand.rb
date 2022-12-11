# frozen_string_literal: true

#
# $Id$
#
class AllowOddsOfOneThousand < ActiveRecord::Migration[4.2]
  COLS = %i[back1price back2price back3price lay1price lay2price lay3price].freeze
  def up
    COLS.each do |col|
      change_column :market_prices, col, :decimal, precision: 7, scale: 3
    end
  end

  def down
    COLS.each do |col|
      change_column :market_prices, col, :decimal, precision: 6, scale: 3
    end
  end
end

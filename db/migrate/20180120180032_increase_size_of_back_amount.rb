# frozen_string_literal: true

#
# $Id$
#
class IncreaseSizeOfBackAmount < ActiveRecord::Migration[4.2]
  # Need to cope with amounts greater than £1m which is the limit for 8,2
  def up
    change_column :market_prices, :back1amount, :decimal, precision: 9, scale: 2
    change_column :market_prices, :back2amount, :decimal, precision: 9, scale: 2
    change_column :market_prices, :back3amount, :decimal, precision: 9, scale: 2
    change_column :market_prices, :lay1amount, :decimal, precision: 9, scale: 2
    change_column :market_prices, :lay2amount, :decimal, precision: 9, scale: 2
    change_column :market_prices, :lay3amount, :decimal, precision: 9, scale: 2
  end

  def down
    change_column :market_prices, :back1amount, :decimal, precision: 8, scale: 2
    change_column :market_prices, :back2amount, :decimal, precision: 8, scale: 2
    change_column :market_prices, :back3amount, :decimal, precision: 8, scale: 2
    change_column :market_prices, :lay1amount, :decimal, precision: 8, scale: 2
    change_column :market_prices, :lay2amount, :decimal, precision: 8, scale: 2
    change_column :market_prices, :lay3amount, :decimal, precision: 8, scale: 2
  end
end

# frozen_string_literal: true

#
# $Id$
#
class FixBetSizeInEventBasketPrice < ActiveRecord::Migration[4.2]
  def up
    change_column :event_basket_prices, :betsize, :decimal, precision: 8, scale: 2
  end

  def down
    change_column :event_basket_prices, :betsize, :decimal, precision: 10, scale: 0
  end
end

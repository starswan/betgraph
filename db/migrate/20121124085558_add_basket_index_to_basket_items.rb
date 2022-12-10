# frozen_string_literal: true

#
# $Id$
#
class AddBasketIndexToBasketItems < ActiveRecord::Migration[4.2]
  def change
    add_index :event_basket_prices, :basket_id
    add_index :baskets, :event_id
  end
end

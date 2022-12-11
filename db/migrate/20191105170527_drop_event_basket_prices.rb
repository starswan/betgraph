# frozen_string_literal: true

#
# $Id$
#
class DropEventBasketPrices < ActiveRecord::Migration[5.1]
  def up
    drop_table :event_basket_prices
  end

  def down
    create_table "event_basket_prices" do |t|
      t.integer "basket_id"
      t.datetime "time"
      t.decimal "price", precision: 7, scale: 5
      t.decimal "betsize", precision: 8, scale: 2
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index %w[basket_id], name: "index_event_basket_prices_on_basket_id"
    end
  end
end

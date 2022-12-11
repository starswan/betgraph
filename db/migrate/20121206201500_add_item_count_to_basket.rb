# frozen_string_literal: true

#
# $Id$
#
class AddItemCountToBasket < ActiveRecord::Migration[4.2]
  def up
    add_column :baskets, :basket_items_count, :integer, null: false, default: 0

    count = Basket.count
    Basket.all.includes(%i[basket_items event]).each_with_index do |basket, index|
      say_with_time "#{basket.name} #{basket.event.description} #{index}/#{count}" do
        basket.basket_items_count = basket.basket_items.count
        basket.save!
      end
    end
  end

  def down
    remove_column :baskets, :basket_items_count
  end
end

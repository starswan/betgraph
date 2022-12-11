# frozen_string_literal: true

#
# $Id$
#
class AddUniqueIndexToBasketItems < ActiveRecord::Migration[4.2]
  def change
    add_index :basket_items, %i[basket_id market_runner_id], unique: true
  end
end

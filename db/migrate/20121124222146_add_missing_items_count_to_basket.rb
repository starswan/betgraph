# frozen_string_literal: true

#
# $Id$
#
class AddMissingItemsCountToBasket < ActiveRecord::Migration[4.2]
  def change
    add_column :baskets, :missing_items_count, :integer, null: false
  end
end

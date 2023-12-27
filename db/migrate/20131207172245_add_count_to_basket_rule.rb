# frozen_string_literal: true

#
# $Id$
#
class AddCountToBasketRule < ActiveRecord::Migration[4.2]
  def up
    change_table :basket_rules do |t|
      t.integer :count, null: false, default: 0
    end
    BasketRule.all.find_each do |rule|
      rule.count = rule.basket_rule_items.count
      rule.save!
    end
  end

  def down
    remove_column :basket_rules, :count
  end
end

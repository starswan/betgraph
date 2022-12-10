# frozen_string_literal: true

#
# $Id$
#
class DropPricesTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :prices

    add_foreign_key :menu_sub_paths, :menu_paths, column: :parent_path_id
    add_foreign_key :menu_sub_paths, :menu_paths
    remove_foreign_key :baskets, :basket_rules
    change_column :baskets, :basket_rule_id, :integer
    change_column :basket_rules, :id, :integer, unique: true, null: false, auto_increment: true
    add_foreign_key :baskets, :basket_rules
  end
end

# frozen_string_literal: true

#
# $Id$
#
class TwoPhaseBetMarketCreation < ActiveRecord::Migration[4.2]
  def up
    change_table :bet_markets do |t|
      t.decimal :total_matched_amount, precision: 10, scale: 2, null: false
      t.integer :number_of_runners, null: false
    end
    change_column :bet_markets, :description, :string, limit: 2000, null: false
    change_column :bet_markets, :type_variant, :string, null: true
  end

  def down
    change_column :bet_markets, :type_variant, :string, null: false
    change_column :bet_markets, :description, :string, null: false

    remove_column :bet_markets, :number_of_runners
    remove_column :bet_markets, :total_matched_amount
  end
end

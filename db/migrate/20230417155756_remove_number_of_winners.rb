# frozen_string_literal: true

class RemoveNumberOfWinners < ActiveRecord::Migration[6.1]
  def change
    change_table :bet_markets, bulk: true do
      remove_column :bet_markets, :number_of_winners, :integer
      remove_column :bet_markets, :runners_may_be_added, :boolean, null: false
    end
  end
end

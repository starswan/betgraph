# frozen_string_literal: true

class RemoveMarketIdUniqueIndex < ActiveRecord::Migration[6.1]
  def change
    change_table :bet_markets, buik: true do
      remove_index :bet_markets, :marketid
      add_index :bet_markets, [:marketid, :deleted_at], unique: true
    end
  end
end

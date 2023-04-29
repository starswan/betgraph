# frozen_string_literal: true

class RemoveMarketIdUniqueIndex < ActiveRecord::Migration[6.1]
  def change
    remove_index :bet_markets, :marketid
    add_index :bet_markets, [:marketid, :deleted_at], unique: true
  end
end

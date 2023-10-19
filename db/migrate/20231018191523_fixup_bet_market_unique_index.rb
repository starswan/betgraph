class FixupBetMarketUniqueIndex < ActiveRecord::Migration[6.1]
  def change
    change_table :bet_markets, bulk: true do
      remove_index :bet_markets, [:name, :match_id], unique: true
      add_index :bet_markets, [:name, :match_id, :deleted_at], unique: true
    end
  end
end

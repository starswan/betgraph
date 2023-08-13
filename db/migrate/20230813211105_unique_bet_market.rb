class UniqueBetMarket < ActiveRecord::Migration[6.1]
  def change
    change_table :bet_markets do |t|
      t.index [:name, :match_id], unique: true
    end
  end
end

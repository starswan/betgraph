class UniqueRunnerDesc < ActiveRecord::Migration[6.1]
  def change
    add_index :market_runners, [:description, :bet_market_id, :handicap], name: "index_runners_on_desc_bet_market_handicap", unique: true
  end
end

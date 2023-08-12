class AddVersionToMarket < ActiveRecord::Migration[6.1]
  def change
    change_table :bet_markets do |t|
      t.bigint :version
    end
  end
end

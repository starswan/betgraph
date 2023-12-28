class AddPriceSourceToBetMarket < ActiveRecord::Migration[6.1]
  def change
    change_table :bet_markets do |t|
      t.string :price_source, null: false, default: "RestAPI"
    end
    change_column_default :bet_markets, :price_source, from: "RestAPI", to: nil
  end
end

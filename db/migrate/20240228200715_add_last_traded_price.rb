class AddLastTradedPrice < ActiveRecord::Migration[6.1]
  def up
    change_table :market_prices do |t|
      t.decimal :last_traded_price, precision: 9, scale: 2
    end

    BetMarket.includes(market_runners: :market_prices).with_historical_prices.find_each do |bm|
      bm.market_runners.each do |mr|
        mr.market_prices.each do |p|
          p.update!(last_traded_price: p.back1price, back1price: nil)
        end
      end
    end
  end

  def down
    BetMarket.includes(market_runners: :market_prices).with_historical_prices.find_each do |bm|
      bm.market_runners.each do |mr|
        mr.market_prices.each do |p|
          p.update!(back1price: p.last_traded_price)
        end
      end
    end

    remove_column :market_prices, :last_traded_price
  end
end

#
# $Id$
#
class AddLastTradedPrice < ActiveRecord::Migration[6.1]
  BATCH_SIZE = 500

  def up
    # change_table :market_prices do |t|
    #   t.decimal :last_traded_price, precision: 9, scale: 2
    # end

    market_price_records.each do |p|
      p.update!(last_traded_price: p.back1price, back1price: nil)
    end
  end

  def down
    market_price_records.each do |p|
      p.update!(back1price: p.last_traded_price)
    end

    remove_column :market_prices, :last_traded_price
  end

private

  def market_price_records
    Enumerator.new do |yielder|
      count = BetMarket.with_historical_prices.count
      index = 0
      BetMarket.includes(market_runners: { market_prices: :market_price_time }).with_historical_prices.find_in_batches(batch_size: BATCH_SIZE) do |batch|
        say_with_time "#{Time.zone.now} BetMarket Price Fixup #{index}/#{count}" do
          batch.each do |bm|
            bm.market_runners.each do |mr|
              mr.market_prices.each { |z| yielder << z }
            end
          end
          index += BATCH_SIZE
        end
      end
    end
  end
end

# frozen_string_literal: true

markets = [BetMarket.first]
while markets.size > 0
  markets = BetMarket.includes(:market_price_times).find_each.select do |bm|
    bm.market_price_times.size > 1 && bm.market_price_times[-1].time - bm.market_price_times[-2].time > 300
  end
  puts "Cleaning #{markets.size} markets"
  markets.each { |s| s.market_price_times.last.destroy }
end

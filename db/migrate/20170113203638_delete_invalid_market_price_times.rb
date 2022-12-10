# frozen_string_literal: true

#
# $Id$
#
class DeleteInvalidMarketPriceTimes < ActiveRecord::Migration[4.2]
  def up
    count = Match.count
    Match.includes(bet_markets: { market_price_times: :market_prices }).find_each(batch_size: 5).with_index do |match, index|
      say_with_time("match #{index}/#{count} [#{100.0 * index / count}%] #{match.kickofftime} #{match.name} #{match.bet_markets_count}") do
        next if match.bet_markets_count == 0

        match.bet_markets.each do |bet_market|
          bet_market.market_price_times.each { |market_price_time| market_price_time.destroy unless market_price_time.valid? }
        end
      end
    end
  end
end

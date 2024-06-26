# frozen_string_literal: true

class RemoveMarketWithGapJob < ApplicationJob
  queue_priority PRIORITY_REMOVE_MARKETS_WITH_GAPS

  def perform(market)
    # Delete closed markets if there are any large gaps in the price trail.
    market.each do |id|
      bet_market = BetMarket.includes(market_runners: { market_prices: :market_price_time }).find(id)
      # TODO: this could be a lot better maybe?
      next unless bet_market.market_runners.map(&:market_prices).flatten
        .select { |mp| mp.market_price_time.time >= mp.bet_market.match.kickofftime && mp.market_price_time.time < mp.bet_market.match.endtime }
        .each_cons(2).select { |t1, t2| t2.market_price_time.time - t1.market_price_time.time > 8.minutes }.any?

      destroy_object(bet_market)
    end
  end
end

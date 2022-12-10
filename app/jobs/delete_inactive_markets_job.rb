# frozen_string_literal: true

#
# $Id$
#
class DeleteInactiveMarketsJob < ApplicationJob
  queue_priority PRIORITY_DESTROY_OBJECT

  # This calculation is unclear. If the market closes early (e.g. under 1 goal)
  # then the data is useful and correct, but if the market hasn't really closed then its useless.
  SENSIBLE_MARKET_PRICE_COUNT = 6

  def perform
    BetMarket.where(market_prices_count: 0).each do |bet_market|
      destroy_object(bet_market) unless bet_market.open?
    end
    # how to replace this now market_price_times at match level...?
    # BetMarket.closed.where("market_price_times_count < ?", SENSIBLE_MARKET_PRICE_COUNT).each do |bm|
    #   destroy_object(bm)
    # end
    #
    # Match.where('market_price_times_count > 0 and market_price_times_count < 300').each { |m| destroy_object(m) }
    # This is the same old problem - some markets naturally terminate early, so you cant just use time to determine
    # if the market should be deleted or not.
    # SoccerMatch.includes(bet_markets: [:market_price_times, :betfair_market_type]).where.not(market_price_times_count: 0).
    #   find_each(batch_size: 10) do |sm|
    #   half_time_markets = sm.bet_markets.half_time
    #   full_time_markets = sm.bet_markets.reject { |bm| bm.half_time? }
    #
    #   first = sm.bet_markets.map { |bm| bm.market_price_times.first.time }.min
    #
    #   if half_time_markets.any?
    #     last_ht = half_time_markets.map { |bm| bm.market_price_times.last.time }.max
    #
    #     if last_ht - first < 35.minutes
    #       half_time_markets.each { |bm| destroy_object(bm) }
    #     end
    #   end
    #
    #   if full_time_markets.any?
    #     last = full_time_markets.map { |bm| bm.market_price_times.last.time }.max
    #
    #     if last - first < 75.minutes
    #       full_time_markets.each { |bm| destroy_object(bm) }
    #     end
    #   end
    # end
  end
end

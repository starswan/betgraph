# frozen_string_literal: true

#
# $Id$
#
class MakeRunnersJob < BetfairJob
  # queue_priority :make_matches_and_runners
  queue_priority PRIORITY_MAKE_RUNNERS

  def perform(bet_market)
    bc.getMarketDetail(bet_market.exchange_id, bet_market.marketid) do |marketdetail|
      logger.debug "getMarket detail #{marketdetail.inspect}"
      railsclient.makeRunners(bet_market, marketdetail)
    end
  end
end

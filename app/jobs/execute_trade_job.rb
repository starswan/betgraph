# frozen_string_literal: true

#
# $Id$
#
class ExecuteTradeJob < BetfairJob
  queue_priority PRIORITY_EXECUTE_TRADE

  def perform(trade)
    runner = trade.market_runner
    bm = runner.bet_market
    prices = bc.get_prices bm.exchange_id, bm.marketid
    runner = trade.market_runner
    bc.place_bet(market_id: prices.fetch(:marketId), selection_id: runner.selectionId, side: trade.side, price: trade.price, size: trade.size)
  end
end

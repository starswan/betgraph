# frozen_string_literal: true

#
# $Id$
#
class ExecuteTradeJob < BetfairJob
  queue_priority PRIORITY_EXECUTE_TRADE

  def perform(trade)
    runner = trade.market_runner
    bm = runner.bet_market
    market_data = bc.findMarket(bm)
    bc.getPrices(market_data) do |marketWithPrices|
      # logger.debug { "getPrices returned #{marketWithPrices.inspect}" }
      market_runner = marketWithPrices.runners.find { |r| (r.selectionId == runner.selectionId) && (r.asianLineId == runner.asianLineId) }
      logger.debug "MR #{market_runner.inspect}"
      if trade.side == "B"
        market_runner.back price: trade.price, size: trade.size
      else
        market_runner.lay price: trade.price, size: trade.size
      end
    end
  end
end

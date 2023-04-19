# frozen_string_literal: true

class CaptureMatchPricesJob < BetfairJob
  queue_priority PRIORITY_LIVE_PRICES

  MarketId = Struct.new(:exchangeId, :marketId, keyword_init: true)

  def perform(match)
    dbmarkets = match.bet_markets.live
    market_ids = dbmarkets.map { |bm| MarketId.new(exchangeId: bm.exchange_id, marketId: bm.marketid).freeze }
    prices = bc.getMultipleMarketPrices market_ids
    # this puts the prices in the same order as the dbmarkets list
    ordered_prices = market_ids.map { |m| prices.detect { |p| p.fetch(:marketId) == "#{m.exchangeId}.#{m.marketId}" } }
    mpt = MarketPriceTime.create! time: Time.zone.now
    dbmarkets.zip(ordered_prices).each do |dbmarket, market_price|
      ProcessMarketPriceJob.perform_later dbmarket, market_price, mpt
    end
  end
end

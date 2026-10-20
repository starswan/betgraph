# frozen_string_literal: true

class CaptureMatchPricesJob < BetfairJob
  queue_priority PRIORITY_LIVE_PRICES

  MarketId = Data.define(:exchange_id, :market_id)

  def perform(match)
    dbmarkets = match.bet_markets.live
    market_ids = dbmarkets.map { |bm| MarketId.new(exchange_id: bm.exchange_id, market_id: bm.marketid).freeze }
    prices = bc.getMultipleMarketPrices market_ids
    # this puts the prices in the same order as the dbmarkets list
    ordered_prices = market_ids.map { |m| prices.detect { |p| p.fetch(:marketId) == "#{m.exchange_id}.#{m.market_id}" } }
    mpt = MarketPriceTime.create! time: Time.zone.now
    dbmarkets.zip(ordered_prices).each do |dbmarket, market_price|
      ProcessMarketPriceJob.perform_later dbmarket, market_price, mpt
    end
  end
end

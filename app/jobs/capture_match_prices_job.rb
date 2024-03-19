# frozen_string_literal: true

class CaptureMatchPricesJob < BetfairJob
  queue_priority PRIORITY_LIVE_PRICES

  def perform(match)
    dbmarkets = match.bet_markets.live
    market_ids = dbmarkets.map(&:betfair_marketid)

    stream = bc.stream
    message = { op: "marketSubscription",
                id: match.id,
                marketFilter: {
                  marketIds: market_ids,
                  # "bspMarket": true,
                  bettingTypes: %w[ODDS],
                  # "eventTypeIds": %w[1],
                  # eventIds: [match.betfair_event_id],
                  turnInPlayEnabled: true,
                  # "marketTypes": %w[MATCH_ODDS],
                  # "countryCodes": %w[ES],
                },
                marketDataFilter: {} }
    logger.info "Sending subscription #{message}"
    stream.send message.to_json
    stream.each do |json_item|
      item = JSON.parse(json_item, symbolize_names: true)
      if item[:ct] == "SUB_IMAGE"
        market_data = item[:mc]
        # market_ids = market_data.map { |x| x.fetch(:id) }
        # logger.info "Received sub image for markets #{market_ids}"
        market_data.each do |datum|
          logger.info "Received market #{datum}"
        end
      else
        logger.info "Received stream item #{item}"
      end
    end
    # prices = bc.getMultipleMarketPrices market_ids
    # # this puts the prices in the same order as the dbmarkets list
    # ordered_prices = market_ids.map { |m| prices.detect { |p| p.fetch(:marketId) == "#{m.exchangeId}.#{m.marketId}" } }
    # mpt = MarketPriceTime.create! time: Time.zone.now
    # dbmarkets.zip(ordered_prices).each do |dbmarket, market_price|
    #   ProcessMarketPriceJob.perform_later dbmarket, market_price, mpt
    # end
  end
end

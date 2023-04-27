# frozen_string_literal: true

#
# $Id$
#
require "betfair"

class BetfairLogin
  def initialize(_logger)
    login = Login.find_by name: "betfair"
    headers = { "X-Application" => ENV["BETFAIR_API_KEY"] }
    # @bc = Betfair::Client.new headers, { adapter: :net_http_persistent }
    @bc = Betfair::Client.new headers, { adapter: :curb }
    @bc.non_interactive_login(login.username,
                              login.password,
                              add_home(Settings.keyfile),
                              add_home(Settings.certfile))
    # result = @bc.interactive_login(login.username, login.password)

    eventTypes = @bc.list_event_types(filter: {}).map(&:deep_symbolize_keys).map { |z| z.fetch(:eventType) }
    @activeTypes = Sport.active
                      .map { |sport| eventTypes.find { |et| et.fetch(:name) == sport.name } }
  end

  def getMultipleMarketPrices(market_ids)
    list_market_book(market_ids.map { |m| "#{m.exchangeId}.#{m.marketId}" })
  end

  def getActiveEventTypes
    @bc.list_event_types(filter: {}).map(&:deep_symbolize_keys).map { |z| z.fetch(:eventType) }
  end

  def getMarketDetail(exchangeId, marketId)
    @bc.list_market_catalogue(filter: { marketIds: ["#{exchangeId}.#{marketId}"] },
                              marketProjection: %w[RUNNER_METADATA],
                              maxResults: 1000).map(&:deep_symbolize_keys).first
  end

  def keepAlive
    @bc.keep_alive
  end

  def get_markets_for_event(event)
    @bc.list_market_catalogue(
      filter: {
        eventIds: [event.fetch(:id)],
      },
      maxResults: event.fetch(:marketCount),
      marketProjection: %w[RUNNER_METADATA MARKET_DESCRIPTION],
    ).map(&:deep_symbolize_keys)
  end

  def get_all_competitions
    @bc.list_competitions(
      filter: {
        eventTypeIds: @activeTypes.map { |t| t.fetch(:id) },
      },
    ).map(&:deep_symbolize_keys).map { |c| c.except(:competition).merge(c.fetch(:competition)) }
  end

  def get_competitions_for_event(event)
    @bc.list_competitions(
      filter: {
        eventTypeIds: [event.fetch(:id)],
      },
    ).map(&:deep_symbolize_keys).map { |c| c.except(:competition).merge(c.fetch(:competition)) }
  end

  def get_all_events
    Rails.cache.fetch("events", expires_in: Settings.allMarketsCacheTimeout) do
      @bc.list_events(
        filter: {
          eventTypeIds: @activeTypes.map { |t| t.fetch(:id) },
        },
      ).map(&:deep_symbolize_keys).map { |x| x.fetch(:event).merge(marketCount: x.fetch(:marketCount)) }
    end
  end

  def get_events_for_competition(id:)
    @bc.list_events(
      filter: {
        competitionIds: [id],
      },
    ).map(&:deep_symbolize_keys).map { |x| x.fetch(:event).merge(marketCount: x.fetch(:marketCount)) }
  end

  def get_prices(exchange_id, market_id)
    list_market_book(["#{exchange_id}.#{market_id}"]).first
  end

  def place_bet(market_id:, selection_id:, side:, price:, size:)
    place_bet_with_handicap market_id: market_id, selection_id: selection_id, side: side, price: price, size: size, handicap: nil
  end

  def place_bet_with_handicap(market_id:, selection_id:, side:, price:, size:, handicap:)
    @bc.place_orders(
      {
        marketId: market_id,
        instructions: [
          {
            orderType: "LIMIT",
            selectionId: selection_id,
            handicap: handicap,
            side: side == "B" ? "BACK" : "LAY",
            limitOrder: {
              size: size,
              price: price,
              persistenceType: "LAPSE", # This value doesn't matter, but this is s safe default
            },
          },
        ],
      },
    ).deep_symbolize_keys
  end

private

  def list_market_book(market_ids)
    x = @bc.list_market_book(
      marketIds: market_ids.sort,
      priceProjection: {
        priceData: ["EX_BEST_OFFERS"],
        exBestOffersOverrides: { bestPricesDepth: 3 },
      },
    )
    x.map(&:deep_symbolize_keys).map do |h|
      h.except(:runners).merge(runners: h.fetch(:runners).map { |r| r.except(:ex).merge(r.fetch(:ex)) })
    end
  end

  def add_home(setting)
    setting.gsub("~", ENV["HOME"])
  end
end

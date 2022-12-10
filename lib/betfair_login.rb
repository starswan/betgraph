# frozen_string_literal: true

#
# $Id$
#
require "betfair"

class BetfairLogin
  BETFAIR = "betfair"

  def initialize(logger)
    login = Login.find_by name: BETFAIR
    @bc = Betfair::Client.new logger: logger
    @bc.login login.username, login.password
    eventTypes = @bc.getActiveEventTypes
    @activeTypes = Sport.active
                      .map { |sport| eventTypes.find { |et| et.name == sport.name } }
  end

  def getAllMarkets
    Rails.cache.fetch("allMarkets", expires_in: Settings.allMarketsCacheTimeout) do
      @bc.getAllMarkets
    end
  end

  def getMultipleMarketPrices(*args)
    @bc.getMultipleMarketPrices(*args)
  end

  def getActiveEventTypes
    @bc.getActiveEventTypes
  end

  def getMarketDetail(exchangeId, marketId, &block)
    @bc.getMarketDetail exchangeId, marketId, &block
  end

  def keepAlive
    @bc.keepAlive
  end

  def getActiveMarkets
    Rails.cache.fetch("activeMarkets", expires_in: Settings.allMarketsCacheTimeout) do
      @bc.getAllMarkets(eventTypes: @activeTypes)
    end
  end

  def getAllEvents
    @bc.getAllEvents
  end

  def findMarket(market)
    todaysMarkets(market.time).detect do |m|
      m.marketId == market.marketid
    end
  end

  def getPrices(market)
    @bc.getPrices market
  end

private

  def todaysMarkets(today)
    Rails.cache.fetch "todaysMarkets", expires_in: Settings.allMarketsCacheTimeout do
      @bc.getAllMarkets(fromDate: today, toDate: today)
    end
  end

  # def getActiveMarketsBySport
  #   eventTypes = @bc.getActiveEventTypes
  #   activeSports = Sport.find_all_by_active(true)
  #   activeTypes = activeSports.collect { |sport| eventTypes.find { |et| et.name == sport.name } }.select { |type| type }
  #   activeTypes.inject(Hash.new) { |hash, type| @bc.getAllMarkets(:eventTypes => [type]) }
  # end
end

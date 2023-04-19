# frozen_string_literal: true

#
# $Id$
#
require "market_pricer"

class TriggerLivePricesJob < BetfairJob
  # queue_priority :live_prices
  queue_priority PRIORITY_LIVE_PRICES

  def perform
    capture_live_prices if BetMarket.activelive.any?
  end

private

  # In order to construct a SimpleMarket we need:
  # id (splits into exchangeId and marketId)
  # marketName
  # marketTime
  # totalMatched
  # runners
  # marketType
  # numberOfWinners
  # If we have a 2-horse race and the largest back1price is big, then we don't want to fetch it for N seconds after
  # the last fetch. Overrounds don't work here - they are more for early markets with poor price depth
  # max price is 1000 (which presumably means don't bother again) and min is 2ish (which means do it now)
  # I guess there's a continuum here - maybe up to 10 its minutes/poll, after that it's up to 20 or 45 mins away.
  def capture_live_prices
    all_market_ids = Set.new
    groups = []
    BetMarket.transaction do
      # activelive = BetMarket.activelive.where(marketid: all_markets_hash.keys)
      activelive = BetMarket.activelive
      activelive.group_by { |m| m.match_id }.values.map { |g| g.compact }.each do |priced_markets|
        # priced_markets is a list of markets for one match
        market_ids = priced_markets.map { |market| Struct.new(:exchangeId, :marketId).new(market.exchange_id, market.marketid) }
        prices = bc.getMultipleMarketPrices market_ids
        all_market_ids << prices.map { |p| p.fetch(:marketId) }
        # this puts the prices in the same order as the priced_markets list
        ordered_prices = market_ids.map { |m| prices.detect { |p| p.fetch(:marketId) == "#{m.exchangeId}.#{m.marketId}" } }
        priced_markets.zip(ordered_prices).each do |dbmarket, market_price|
          mpt = MarketPriceTime.new time: Time.now
          dopricesformarket market_price, dbmarket, mpt do |price_group|
            groups << price_group
          end
        end
      end
      activelive.reject { |dbmarket| dbmarket.marketid.in? all_market_ids }.select { |bm| Time.now > bm.match.endtime }.each do |dbmarket|
        logger.debug "closing non-priced market #{dbmarket.name} after event ended"
        dbmarket.update!(status: BetMarket::CLOSED)
      end
    end
  end

  Prices = Struct.new :status, :availableToBack, :availableToLay, keyword_init: true

  def dopricesformarket(market_price, dbmarket, mpt)
    #
    # This was a nice idea for non in-play markets, but never fully implemented.
    # If dbmarket.time > now, then set dbmarket.nextUpdateTime to something so that:
    # if overRound = 200%, then nextUpdateTime = time - (time - now) / 2
    # if overRound = 300%, then nextUpdateTime = time - 2 * (time - now) / 3 (i.e. 1/3rd of time remaining)
    #
    # market.numberOfWinners is zero for some types of market.
    # unless market.inPlay? or market.numberOfWinners == 0
    #  pricer = MarketPricer.new mpc
    #  if pricer.layOverround == 0
    #    overRound = pricer.backOverround / market.numberOfWinners
    #  else
    #    overRound = (pricer.backOverround + 1 / pricer.layOverround) / (2 * market.numberOfWinners)
    #  end
    #  dbmarket.nextUpdateTime = market.marketTime - (market.marketTime - now) / overRound if overRound > 0
    #  dbmarket.save! if dbmarket.nextUpdateTime > now
    # end
    logger.debug "#{dbmarket.name} market_price #{market_price.inspect}"
    if market_price.fetch(:status) != dbmarket.status
      logger.debug "changing market #{dbmarket.name} status from #{dbmarket.status} to #{market_price.fetch(:status)}"
      dbmarket.update!(status: market_price.fetch(:status))
    end
    prices = convert_runner_prices_to_hash(market_price.fetch(:runners))
    unless prices.empty?
      group = PriceGroup.new time: mpt.time, market_prices: [], bet_market: dbmarket
      dbmarket.market_runners.each do |dbrunner|
        price = prices[dbrunner.selectionId]
        next unless price

        pricelist = price[dbrunner.handicap.to_s]
        # This price might not be always valid - so allow the validation
        # to strip it out in this case. e.g. when there are no prices or when they are just complete nonsense
        if pricelist
          mp = MarketPrice.new market_runner: dbrunner,
                               market_price_time: mpt,
                               status: pricelist.status,
                               back1price: extract_price(pricelist.availableToBack, 0),
                               back1amount: extract_amount(pricelist.availableToBack, 0),
                               lay1price: extract_price(pricelist.availableToLay, 0),
                               lay1amount: extract_amount(pricelist.availableToLay, 0),
                               back2price: extract_price(pricelist.availableToBack, 1),
                               back2amount: extract_amount(pricelist.availableToBack, 1),
                               lay2price: extract_price(pricelist.availableToLay, 1),
                               lay2amount: extract_amount(pricelist.availableToLay, 1),
                               back3price: extract_price(pricelist.availableToBack, 2),
                               back3amount: extract_amount(pricelist.availableToBack, 2),
                               lay3price: extract_price(pricelist.availableToLay, 2),
                               lay3amount: extract_amount(pricelist.availableToLay, 2)
          group.market_prices << mp
        end
      end
      if group.valid?
        group.market_prices.each(&:save!)
        yield group
      end
    end
  end

  def convert_runner_prices_to_hash(runners)
    prices = {}
    runners.reject { |r| r.fetch(:status) == "ACTIVE" && (r.fetch(:availableToBack).empty? && r.fetch(:availableToLay).empty?) }.each do |runner|
      prices[runner.fetch(:selectionId)] ||= {}
      prices[runner.fetch(:selectionId)][runner.fetch(:handicap).to_s] = Prices.new(status: runner.fetch(:status),
                                                                                    availableToBack: runner.fetch(:availableToBack),
                                                                                    availableToLay: runner.fetch(:availableToLay))
    end
    prices
  end

  def extract_price(price, index)
    price[index].fetch(:price) if price[index]
  end

  def extract_amount(price, index)
    price[index].fetch(:size) if price[index]
  end
end

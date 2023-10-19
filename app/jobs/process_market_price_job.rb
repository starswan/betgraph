# frozen_string_literal: true

class ProcessMarketPriceJob < ApplicationJob
  queue_priority PRIORITY_LIVE_PRICES

  def perform(dbmarket, market_price, mpt)
    BetMarket.transaction do
      dopricesformarket market_price, dbmarket, mpt
    end
  end

private

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
        next unless pricelist

        0.upto(2) do |index|
          mp = Price.new market_runner: dbrunner,
                         market_price_time: mpt,
                         depth: index + 1,
                         back_price: extract_price(pricelist.availableToBack, index),
                         back_amount: extract_amount(pricelist.availableToBack, index),
                         lay_price: extract_price(pricelist.availableToLay, index),
                         lay_amount: extract_amount(pricelist.availableToLay, index)
          group.market_prices << mp if mp.valid?
        end
      end
      if group.valid?
        group.market_prices.each(&:save!)
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

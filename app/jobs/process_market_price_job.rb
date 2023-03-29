# frozen_string_literal: true

class ProcessMarketPriceJob < ApplicationJob
  queue_priority PRIORITY_LIVE_PRICES

  def perform(dbmarket, market_price, mpt)
    dopricesformarket market_price, dbmarket, mpt
  end

private

  Prices = Struct.new :status, :prices

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
    if market_price.status != dbmarket.status
      logger.debug "changing market #{dbmarket.name} status from #{dbmarket.status} to #{market_price.status}"
      dbmarket.update!(status: market_price.status)
    end
    prices = convert_runner_prices_to_hash(market_price.runners)
    unless prices.empty?
      group = PriceGroup.new time: mpt.time, market_prices: [], bet_market: dbmarket
      dbmarket.market_runners.each do |dbrunner|
        price = prices[dbrunner.selectionId]
        next unless price

        pricelist = price[dbrunner.handicap.to_s]
        # This price might not be always valid - so allow the validation
        # to strip it out in this case. e.g. when there are no prices or when they are just complete nonsense
        next unless pricelist

        mp = MarketPrice.new market_runner: dbrunner,
                             market_price_time: mpt,
                             status: pricelist.status,
                             back1price: back_price(pricelist.prices, 0),
                             back1amount: back_amount(pricelist.prices, 0),
                             lay1price: lay_price(pricelist.prices, 0),
                             lay1amount: lay_amount(pricelist.prices, 0),
                             back2price: back_price(pricelist.prices, 1),
                             back2amount: back_amount(pricelist.prices, 1),
                             lay2price: lay_price(pricelist.prices, 1),
                             lay2amount: lay_amount(pricelist.prices, 1),
                             back3price: back_price(pricelist.prices, 2),
                             back3amount: back_amount(pricelist.prices, 2),
                             lay3price: lay_price(pricelist.prices, 2),
                             lay3amount: lay_amount(pricelist.prices, 2)
        group.market_prices << mp
      end
      if group.valid?
        group.market_prices.each(&:save!)
      end
    end
  end

  def convert_runner_prices_to_hash(runners)
    runners.reject { |r| r.status == "ACTIVE" && (r.ex.availableToBack.empty? && r.ex.availableToLay.empty?) }.each_with_object({}) do |runner, prices|
      prices[runner.selectionId] ||= {}
      prices[runner.selectionId][runner.handicap.to_s] = Prices.new(runner.status, runner.ex)
    end
  end

  def back_price(price, index)
    price.availableToBack[index].price if price.availableToBack[index]
  end

  def back_amount(price, index)
    price.availableToBack[index].size if price.availableToBack[index]
  end

  def lay_price(price, index)
    price.availableToLay[index].price if price.availableToLay[index]
  end

  def lay_amount(price, index)
    price.availableToLay[index].size if price.availableToLay[index]
  end
end

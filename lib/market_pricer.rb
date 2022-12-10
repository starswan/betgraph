# frozen_string_literal: true

#
# $Id$
#
# Split out pricing capaibility from Market implementation so that any market that provides the correct
# methods can be priced - including Betfair MarketWithPrices and the RoR model objects. Of course the RoR
# model will need to use an adapter, as it will have many prices and needs to pick a point in time.
#
class MarketPricer
  def initialize(market)
    @market = market
  end

  # Expected to be near but > numberOfWinners.
  # Closer to numberOfWinners the more tightly-priced the market is.
  # Divide by numberOfWinners to produce same % numbers as betfair
  def backOverround(targetAmount = 1)
    probability = 0
    @market.runners.each do |r|
      amount = 0
      pricetotal = 0
      r.bestPricesToBack.each do |bestPrice|
        pricetotal += bestPrice.amountAvailable / bestPrice.price
        amount += bestPrice.amountAvailable
        break if amount >= targetAmount
      end
      probability += amount >= targetAmount ? pricetotal / amount : 1
    end
    probability
  end

  #
  # Lay overround as a fraction. Closer to numberOfWinners, the more efficient the market.
  # Expect to be near but < numberOfWinners
  # Do it this way round to avoid wrong answers if one runner doesn't have a price
  #
  def layOverround(_targetAmount = 1)
    probability = 0
    @market.runners.each do |r|
      probability += (r.bestPricesToLay.size > 0) ? 1 / r.bestPricesToLay[0].price : 0
    end
    probability
  end
end

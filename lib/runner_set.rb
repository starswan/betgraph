# frozen_string_literal: true

#
# $Id$
#
# hash of runners against priceSet, so that overRound can be calculated
# for a group of runners (either market or basket)
#
class RunnerSet
  def initialize
    @priceSets = {}
    @minAmount, @maxPrice, @overRound = nil, nil, nil
  end

  def addPriceSet(runnerKey, priceSet)
    @priceSets[runnerKey] = priceSet unless priceSet.empty?
    @minAmount, @maxPrice, @overRound = nil, nil, nil # reset cached values
  end

  def count
    @priceSets.size
  end

  def overRound
    # If there is no data, then this should produce a big value rather than zero
    @overRound ||= @priceSets.empty? ? 999 : @priceSets.values.collect { |ps| ps.overRound }.sum
  end

  def maxPrice
    @maxPrice ||= @priceSets.values.collect { |p| p.price < 999 ? p.price : 0 }.max
  end

  def minAmount
    @minAmount ||= @priceSets.values.collect { |p| p.minAmount }.min
  end

  def effectivePrices
    # @priceSets.each do |runner, priceSet|
    #   effectivePrice, bet = priceSet.effectivePrice(maxPrice * minAmount)
    #   yield runner, effectivePrice, bet, priceSet.betType if effectivePrice < 999
    # end
    @priceSets.map { |runner, priceSet|
      [runner, priceSet] + priceSet.effectivePrice(maxPrice * minAmount)
    }.select { |_r, _ps, ep, _b| ep < 999 }.map { |r, ps, ep, b| [r, ep, b, ps.betType] }
  end
end

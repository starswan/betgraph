# frozen_string_literal: true

#
# $Id$
#
module Soccer
  #
  # This is the sum of 2 Poisson-distributed variables
  # Current implementation of expected assumes that it is one Poisson-distributed variable
  #
  class OverUnderGoals < FullTimeValuer
    def value(homevalue, _awayvalue, homescore, awayscore)
      homevalue > 0 ? homescore + awayscore <=> homevalue : -homevalue <=> homescore + awayscore
    end

    # This needs to work backwards from the price to come up with a
    # value for expected arrivals aka lambda
    # P(x) == (lambda ^ x)*(e ^ -lambda)/x!
    # we have P (based on price) and need to calculate lambda
    # by solving (lambda ^ x) * (E ^ -lambda) / x! - P = 0 for lambda using Newton's method
    # x1 = x0 - f(x0) / fdash(x0)
    # pricelist will always contain 2 values bid and ask
    # seems a bit silly - should just pass 1 price and get 1 answer
    def expected_value(marketvalue, pricelist)
      # homevalue is set to -ve for < target, +ve for >target
      pricelist = pricelist.reverse if pricelist.first[:homevalue] > 0
      # probability === 1.0 / backprice e.g bp = 1.06, p = 1/1.06 == almost 1, bp = 2, p = 0.5
      # but backing the layprice of the other item costs something different
      # e.g. p == 0.25 results in [3.9, 4.1] and [1.24, 1.26]
      # implied probability from lp1 is p === 1 / (lp1 - 1) - so maybe this is correct (but slighty obtuse)
      # it would be maybe better to calculate the probability and then convert to a price
      back_first = [pricelist.first[:backprice] - 1, 1.0 / pricelist.last[:layprice]].max
      # back_first = [pricelist.first[:backprice], 1.0 / pricelist.last[:layprice] - 1].max
      back_last = [pricelist.last[:backprice] - 1, 1.0 / pricelist.first[:layprice]].max

      bid_value = value_calc marketvalue, back_first + 1
      ask_value = value_calc marketvalue, 1 + 1.0 / back_last
      OpenStruct.new(bid: bid_value, ask: ask_value)
    end

    def value_calc(market_value, price)
      probability = 1.0 / price
      total_goals = market_value.to_i
      func = CumulativePoisson.new(total_goals, probability)
      # Start from market value so that convergence stands a decent chance
      NewtonsMethod.solve(market_value, func.method(:func), func.method(:funcdash)).value
    end
  end
end

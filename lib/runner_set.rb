# frozen_string_literal: true

#
# $Id$
#
# hash of runners against price_set, so that overRound can be calculated
# for a group of runners (either market or basket)
#
class RunnerSet
  MAX_VAL = 999

  def initialize
    @price_sets = []
    @min_amount, @max_price, @over_round = nil, nil, nil
  end

  def addPriceSet(runner_key, price_set)
    @price_sets << { runner: runner_key, price_set: price_set } unless price_set.empty?
    @min_amount, @max_price, @over_round = nil, nil, nil # reset cached values
  end

  def count
    @price_sets.size
  end

  def over_round
    # If there is no data, then this should produce a big value rather than zero
    @over_round ||= price_sets.empty? ? MAX_VAL : overround
  end

  def max_price
    @max_price ||= price_sets.map { |p| p.price < MAX_VAL ? p.price : 0 }.max
  end

  def min_amount
    @min_amount ||= price_sets.map { |p| p.min_amount }.min
  end

  def max_prices
    w = weights
    factor = w.map { |x| x.fetch(:weight) / x.fetch(:amount) }.max
    w.map { |g| g.merge(weight: (g.fetch(:weight) / factor).round(2)) }
  end

  def price_weights
    weights.map { |g| g.fetch(:weight) }
  end

private

  # Now I'm confused. This produces exactly the same answer for my 4-item
  # test set as the previous (simpler?) version thus implying that the previous version was also correct
  def overround
    w = weights
    sum = w.sum { |c| c.fetch(:weight) }
    x = w.last.fetch(:price) * w.last.fetch(:weight)
    sum / x
    # @price_sets.values.sum { |ps| ps.over_round }
  end

  def weights
    # Input: N runner prices
    # Output: N runner weights so that backing all runners gives same outcome
    # 4 outcomes - one 10%, one 20%, one 20%, one 50%
    # P1 = 11, P2 = 6, P3 = 6, P4 = 2
    # S1 = 6, S2 = 11 gives R1 = 60 - 11, R2 = 55 - 6 = 49
    # S1 = 6, S2 = 11, S3 = 11 gives R1 = 60 - 11 - 11, R2 = 55 - 6 - 11, R3 = 55 - 6 - 11 = 38
    # S1 = 6, S2 = 11, S3 = 11, S4 = 33 gives
    # R1 = 6 * 10 - 55,
    # R2 = 11 * 5 - 50,
    # R3 = 11 * 5 - 50,
    # R4 = 33 * 1 - 28 == 5 in all cases
    @price_sets.reduce([]) do |array, ps|
      item = ps.fetch(:price_set)
      runner = ps.fetch(:runner)
      case array.size
      when 0
        array << { price: item.price, weight: item.price, amount: item.amount, runner: runner }
      when 1
        [{ price: array.last.fetch(:price), weight: item.price, amount: item.amount, runner: runner },
         { price: item.price, weight: array.last.fetch(:weight), amount: array.last.fetch(:amount), runner: array.last.fetch(:runner) }]
      else
        w = array.last.fetch(:price) * array.last.fetch(:weight)
        array << { price: item.price, weight: w / item.price, amount: item.amount, runner: runner }
      end
    end
  end

  def target
    price_sets.map { |ps| ps.amount * ps.price }.min
  end

  def price_sets
    @price_sets.map { |p| p.fetch(:price_set) }
  end
end

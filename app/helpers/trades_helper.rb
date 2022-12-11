# frozen_string_literal: true

#
# $Id$
#
module TradesHelper
  VALID_PRICE_BANDS = [[0.01, 2, "%.2f"],
                       [0.02, 3, "%.2f"],
                       [0.05, 4, "%.2f"],
                       [0.1,  6, "%.1f"],
                       [0.2, 10, "%.1f"],
                       [0.5, 20, "%.1f"],
                       [1,   30, "%d"],
                       [2,   50, "%d"],
                       [5,  100, "%d"],
                       [10, 1000, "%d"]].freeze

  VALID_BET_SIZES = [2, 3].freeze

  def valid_prices
    start = 1
    valids = VALID_PRICE_BANDS.collect do |jump, end_band, fmt|
      first = start + jump
      start = end_band
      (first..end_band).step(jump).collect { |item| [fmt % item, 100 * item / 100] }
    end
    result = []
    valids.each { |v| v.each { |x| result << x } }
    result
  end

  def valid_bet_sizes
    VALID_BET_SIZES.collect { |x| [x, x] }
  end
end

# frozen_string_literal: true

#
# $Id$
#
require "price_set"

class LayPriceSet < PriceSet
  attr_reader :min_amount

  def initialize(*args)
    super "L"
    @min_amount = nil
    args.each do |price, amount|
      addPrice price, amount
    end
  end

  # If lay price = 1.5, then return £2, risk is £1, minimum risk is £1 = 2 * (price - 1)
  # Back @1.5 means risk 2, get 1 if wins hence Lay@1.5 = risk 1, get 2 if wins i.e. 2/1(3.0)
  # Back @2.0 means risk 2, get 2 if wins (evens) hence Lay@2.0 is the same
  # l(1.5) == 3
  # b(2) == l(2) == 2
  # Back @1.2 means risk 5, win 1 hence Lay@1.2 means risk 1, win 5 i.e. 6.0(5/1)
  # b(x) = x, so l(x) != 1 + 1/x -> l(x) === 1 + 1/(x-1)
  # If lay price = 2, then minimum risk is £2
  # If lay price = 3, then minimum risk is £4
  def addPrice(price, amount)
    if price
      factor = price - 1.0
      addRawPrice 1 + 1 / factor, amount * factor
      minRisk = MINIMUM_BET_AMOUNT * factor
      @min_amount = minRisk if @min_amount.nil? || (@min_amount > minRisk)
    end
  end
end

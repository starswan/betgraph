# frozen_string_literal: true

#
# $Id$
#
require "price_set"

class BackPriceSet < PriceSet
  def initialize(*args)
    super "B"
    args.each do |price, amount|
      addPrice price, amount
    end
  end

  def addPrice(price, amount)
    addRawPrice price, amount if price
  end

  def min_amount
    MINIMUM_BET_AMOUNT
  end
end

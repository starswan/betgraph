# frozen_string_literal: true

#
# $Id$
#
module MarketPriceTimesHelper
  def find_price(price, _amount)
    price.back1price
  end

  def pricetime(pricetime)
    pricetime.strftime("%H:%M:%S")
  end
end

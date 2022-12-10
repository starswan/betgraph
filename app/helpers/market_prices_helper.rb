# frozen_string_literal: true

#
# $Id$
#
module MarketPricesHelper
  def amount(value)
    if value
      value = (value * 100).to_i / 100.0
      value = "%.2f" % value
      "&pound;#{value}".html_safe
    end
  end
end

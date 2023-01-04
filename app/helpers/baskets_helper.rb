# frozen_string_literal: true

#
# $Id$
#
module BasketsHelper
  def basket_data(baskets)
    baskets.map do |basket|
      prices = basket.event_basket_prices.select { |p| p.fetch(:time) >= basket.match.kickofftime }
      {
        id: basket.id,
        label: basket.basket_rule.name,
        prices: prices.map { |p| [p.fetch(:time), p.fetch(:price).to_f.round(4)] }.to_h,
      }
    end
  end
end

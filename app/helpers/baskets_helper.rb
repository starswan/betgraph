# frozen_string_literal: true

#
# $Id$
#
module BasketsHelper
  def basket_data(baskets)
    baskets.map do |basket|
      prices = basket.event_basket_prices.select { |p| p.time >= basket.match.kickofftime }
      {
        id: basket.id,
        label: basket.basket_rule.name,
        prices: prices.map { |p| [p.time, p.price.to_f.round(4)] }.to_h,
      }
    end
  end
  # def basket_chart_data baskets
  #   baskets.map do |basket|
  #     basket.event_basket_prices
  #         .select { |p| p.time >= basket.match.kickofftime }
  #         .map do |price|
  #       {
  #           time: price.time,
  #           basket.id => price.price.to_f
  #       }
  #     end
  #   end.flatten
  # end
end

# frozen_string_literal: true

#
# $Id$
#
module BetMarketsHelper
  def bet_market_data(markets)
    flatten_winners(markets).map do |runner|
      prices = runner.prices.select { |p| p.created_at >= runner.bet_market.time && p.back_price.present? }
      {
        label: "#{runner.bet_market.name} (#{runner.runnername})",
        prices: prices.map { |p| [p.created_at, p.back_price] }.to_h,
      }
    end
  end

  def runner_market_data(_match, runners)
    runners.map do |runner|
      prices = runner.market_prices.select { |p| p.market_price_time.time >= runner.bet_market.time && p.back1price && p.lay1price && p.back1price < runner.bet_market.market_runners_count * 5 }
      # prices = runner.market_prices.select { |p| p.market_price_time.time >= runner.bet_market.time && p.back1price && p.lay1price }
      {
        name: runner.runnername,
        # data: prices.map { |p| [p.market_price_time.time, (1 - 1 / p.back1price).round(4)] }.to_h,
        data: prices.map { |p| [p.market_price_time.time, 1 / p.back1price] }.to_h,
        # data: prices.map { |p|
        #         price = p.back_price_set.effectivePrice(2)[0]
        #         [p.market_price_time.time, (1 / price).round(4)]
        #       }.to_h,
      }
    end
  end

  # below here is the legacy code used for morris.js - it's too tightly bound to the library
  def bet_markets_labels(markets)
    market_runner_labels flatten_winners(markets)
  end

  def bet_markets_ykeys(markets)
    runner_ykeys flatten_winners(markets)
  end

  def market_chart_data(markets)
    runner_chart_data flatten_winners(markets)
  end

  def runner_ykeys(runners)
    runners.map(&:id)
  end

  def best_price_for_runner(market_price_time, risk_amount); end

  def runner_chart_data(runners)
    runners.map { |runner|
      runner.prices
          .select { |p| p.created_at >= runner.bet_market.time && p.back_price.present? }
          .map do |price|
        {
          time: price.created_at,
          runner.id => price.back_price.to_f,
        }
      end
    }.flatten
  end

  def market_runner_labels(runners)
    runners.map { |runner| "#{runner.bet_market.name} (#{runner.runnername})" }
  end

  def basket_runner_labels(basket_items)
    basket_items.map { |bi| "[#{bi.basket.name}] #{bi.market_runner.bet_market.name} (#{bi.market_runner.runnername})" }
  end

  def basket_labels(baskets)
    baskets.map(&:name)
  end

  def basket_ykeys(baskets)
    baskets.map(&:id)
  end

  def runner_labels(runners)
    runners.map(&:runnername)
  end

  def bet_markets_xkey
    "time"
  end

  def winners_for(market)
    market.winners
  end

private

  def flatten_winners(markets)
    markets.map { |m| winners_for(m) }.flatten
  end
  # def displayAmount(value)
  #   value.nil? ? "-" : "&pound;" + h(value)
  # end
  # def displayPrice(value)
  #   value.nil? ? "-" : (100 * value).round / 100.0
  # end
  # def pricetimes(market)
  #   times = market.market_price_times.collect { |time| time.time }
  #   times.sort!.uniq!
  #   times
  # end
end

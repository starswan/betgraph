# frozen_string_literal: true

#
# $Id$
#
module BetMarketsHelper
  def chart_colours
    basics = %w[44 88 cc ff]
    Enumerator.new do |yielder|
      basics.each do |red|
        basics.each do |green|
          basics.each do |blue|
            yielder << "##{red}#{green}#{blue}"
          end
        end
      end
    end
    # "#006600"
    #  "#cc00cc",
    #  "#000000",
    #  "#003399",
    #  "#0000ff",
    #  "#006666",
    #  "#0066cc",
    #  "#00cc00",
    #  "#00cccc",
    #  "#660000",
    #  "#660066",
    #  "#6600cc",
    #  "#666600",
    #  "#666666",
    #  "#6666cc",
    #  "#66cc00",
    #  "#66cc66",
    #  "#66cccc",
    #  "#cc0000",
    #  "#cc0066",
    #  "#cc6600",
    #  "#cc6666",
    #  "#cc66cc",
    #  "#cccc00",
    #  "#cccc66",
    #  "#cccccc",
    #  "#ff0000",
    #  "#ff0066",
    #  "#ff00cc",
    #  "#ff6600",
    #  "#ff6666",
    #  "#ff66cc",
    #  "#ffcc00",
    #  "#ffcc66",
    #  "#ffcccc"]
  end

  def bet_market_data(markets)
    flatten_winners(markets).map do |runner|
      bet_market_runner_data(runner)
    end
  end

  def all_runner_data(markets)
    markets.map(&:market_runners).flatten.map { |r| bet_market_runner_data(r) }
  end

  def bet_market_runner_data(runner)
    # 1000 is often used as a price when an outcome is impossible
    prices = runner.prices.select { |p| p.market_price_time.time >= runner.bet_market.time && p.price_value }
    {
      # id: runner.id,
      label: "#{runner.bet_market.name} (#{runner.runnername})",
      # prices: prices.map { |p| [(p.market_price_time.time - runner.bet_market.time).to_i, p.back1price] }.to_h,
      prices: prices.map { |p| [p.market_price_time.time, p.price_value] }.to_h,
    }
  end

  # :nocov:
  def runner_market_data(_match, runners)
    runners.map do |runner|
      prices = runner.prices.select { |p| p.market_price_time.time >= runner.bet_market.time && p.back_price && p.lay_price && p.back_price < runner.bet_market.market_runners_count * 5 }
      # prices = runner.market_prices.select { |p| p.market_price_time.time >= runner.bet_market.time && p.back1price && p.lay1price }
      {
        name: runner.runnername,
        # data: prices.map { |p| [p.market_price_time.time, (1 - 1 / p.back1price).round(4)] }.to_h,
        data: prices.map { |p| [p.market_price_time.time, 1 / p.back_price] }.to_h,
        # data: prices.map { |p|
        #         price = p.back_price_set.effectivePrice(2)[0]
        #         [p.market_price_time.time, (1 / price).round(4)]
        #       }.to_h,
      }
    end
  end
  # :nocov:

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

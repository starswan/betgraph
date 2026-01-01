# frozen_string_literal: true

#
# $Id$
module BetMarketsHelper
  RED = %w[cc aa 88 44 22].freeze
  GREEN = %w[ee 44 22 88 ff].freeze
  BLUE = %w[aa 88 44 22 11].freeze
  def chart_colours
    # Enumerator.new do |yielder|
    #   RED.each do |red|
    #     GREEN.each do |green|
    #       BLUE.each do |blue|
    #         yielder << "##{red}#{green}#{blue}"
    #       end
    #     end
    #   end
    # end
    %w[
      #6600cc
      #994422
      #00cccc
      #000000
      #0000ff
      #008800
      #22cc66
      #66cc22
      #cc0022
      #003399
      #006666
      #0066cc
      #00cc00
      #660000
      #660066
      #666600
      #666666
      #6666cc
      #66cc00
      #cc0066
      #cc6644
      #cc4466
      #cc6655
      #cc1100
      #66cc66
      #66cccc
      #cc0000
      #cc0066
      #cc6600
      #cc6666
      #cc66cc
      #cccc00
      #55cc66
      #66ddcc
      #cc00ee
      #cc0033
      #cc1100
      #cc9966
      #cc22cc
      #11cc00
      #cccc66
      #cccccc
      #ff0000
      #ff0066
      #ff00cc
      #ff6600
      #ff6666
      #ff66cc
      #11cc66
      #11cccc
      #ff1100
      #ff1166
      #ff22cc
      #ff3300
      #ff4466
      #ff55cc
      #ffcc00
      #ffcc66
      #ffcccc
      #ee88dd
      #aabb22
      #221100
      880044
    ]
  end

  def bet_market_data(markets)
    flatten_winners(markets).map do |runner|
      bet_market_runner_data(runner)
    end
  end

  def all_runner_data(markets)
    markets.map(&:market_runners).flatten.map { |r| bet_market_runner_data(r) }
  end

  def lambda_data(markets, name, limit)
    cs = markets.detect { |bm| bm.betfair_market_type.valuer == name }
    homes = 0.upto(limit).map do |x|
      {
        label: "\u{3BB}H#{x}",
        prices: lambda_home_prices(cs, x),
      }
    end
    aways = 0.upto(limit).map do |x|
      {
        label: "\u{3BB}A#{x}",
        prices: lambda_away_prices(cs, x),
      }
    end
    homes + aways
  end

  def lambda_home_prices(market, goalcount)
    runners = market.market_runners
                    .select { |mr| mr.betfair_runner_type.runnerhomevalue == goalcount }
    # .map { |mr| { prices: mr.market_prices, value: mr.betfair_runner_type.runnerhomevalue } }
    homezero_prices(runners, goalcount, home: true)
  end

  def lambda_away_prices(market, goalcount)
    runners = market.market_runners
                    .select { |mr| mr.betfair_runner_type.runnerawayvalue == goalcount }
    # .map { |mr| { prices: mr.market_prices, value: mr.betfair_runner_type.runnerawayvalue } }
    homezero_prices(runners, goalcount, home: false)
  end

  def homezero_prices(runners, goalcount, home:)
    zeroprices = runners.map(&:market_prices)
                         .reduce(&:+)
                         .sort_by { |p| p.market_price_time.time }
    x = zeroprices.reduce({ size: runners.size, map: {}, list: [] }) { |target, price|
      new = target.fetch(:map).merge({ price.market_runner_id => 1 / price.price_value.to_f })
      # If the sum exceeds 1, a goal has probably been scored so remove runners with a value less than the
      # current (except that its backwards, so I wonder if this works properly?)
      # TODO: write some tests to cover this functionality
      # :nocov:
      (map, size) = if new.values.sum > 1
                      old = if home
                              runners.select { |r| r.betfair_runner_type.runnerawayvalue < price.market_runner.betfair_runner_type.runnerawayvalue }
                            else
                              runners.select { |r| r.betfair_runner_type.runnerhomevalue < price.market_runner.betfair_runner_type.runnerhomevalue }
                            end
                      [new.except(old.map(&:id)), target.fetch(:size) - old.size]
                    else
                      [new, target.fetch(:size)]
                    end
      # :nocov:
      if map.keys.size == size && price.market_price_time.time >= price.market_runner.bet_market.time
        { size: size, map: map, list: target.fetch(:list) + [[price.market_price_time.time, map.values.sum]] }
      else
        { size: size, map: map, list: target.fetch(:list) }
      end
    }.fetch(:list).to_h
    y = x.transform_values do |v|
      hvfunc = Poisson.new(goalcount, v)
      NewtonsMethod.solve(0.5, hvfunc.method(:func), hvfunc.method(:funcdash)).value
    end
    #   # This is for debugging only....
    #   # x.transform_values { |v| (1 / v)  }
    y.compact.transform_values { |z| z.round(3) }
  end

  def bet_market_runner_data(runner)
    # 1000 is often used as a price when an outcome is impossible
    prices = runner.market_prices.select { |p| p.market_price_time.time >= runner.bet_market.time && p.price_value }
    {
      id: runner.id,
      label: "#{runner.bet_market.name} (#{runner.runnername})",
      prices: prices.sort_by { |x| x.market_price_time.time }
                    .map { |p| [((p.market_price_time.time - runner.bet_market.time) / 60).to_i, (1 / p.price_value).round(3)] }.to_h,
    }
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
      runner.market_prices
          .select { |p| p.market_price_time.time >= runner.bet_market.time && p.back1price }
          .map do |price|
        {
          time: price.market_price_time.time,
          runner.id => price.back1price.to_f,
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

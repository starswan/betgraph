namespace :db do
  desc "reset counters"
  task reset_counters: :environment do
    Match.includes([{ bet_markets: { market_runners: :market_prices } }, { baskets: :basket_items }]).find_each(batch_size: 10) do |match|
      if match.bet_markets_count != match.bet_markets.size
        puts "Reset market counters on #{match.name} #{match.kickofftime}"
        Match.reset_counters(match.id, :bet_markets)
      end
      match.bet_markets.each do |bm|
        BetMarket.reset_counters(bm.id, :market_runners) if bm.market_runners_count != bm.market_runners.size
        bm.market_runners.each do |runner|
          MarketRunner.reset_counters(runner.id, :market_prices) if runner.market_prices_count != runner.market_prices.size
        end
      end
      match.baskets.each do |basket|
        Basket.reset_counters(basket.id, :basket_items) if basket.basket_items_count != basket.basket_items.size
      end
    end

    MarketPrice.counter_culture_fix_counts verbose: true
  end

  desc "run tidy up tasks"
  task tidy: :reset_counters do
    # Tasks::Db::YamlLoad::DumpDir.run
  end
end

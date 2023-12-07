namespace :db do
  desc "reset counters"
  task reset_counters: :environment do
    Match.only_deleted.each(&:destroy_fully!)
    BetMarket.only_deleted.each(&:destroy_fully!)

    Match.includes([{ bet_markets: { market_runners: :market_prices } }, { baskets: :basket_items }]).find_each(batch_size: 10) do |match|
      if match.bet_markets_count != match.bet_markets.size
        puts "Reset market counters on #{match.name} #{match.kickofftime}"
        Match.reset_counters(match.id, :bet_markets)
      end
      match.bet_markets.each do |bm|
        if bm.market_runners_count != bm.market_runners.size
          puts "Reset runner counters on #{match.name} #{match.kickofftime} #{bm.name}"
          BetMarket.reset_counters(bm.id, :market_runners)
        end
        bm.market_runners.each do |runner|
          if runner.market_prices_count != runner.market_prices.size
            puts "Reset market price counters on #{match.name} #{match.kickofftime} #{bm.name} #{runner.runnername}"
            MarketRunner.reset_counters(runner.id, :market_prices)
          end
        end
      end
      match.baskets.each do |basket|
        if basket.basket_items_count != basket.basket_items.size
          puts "Reset basket item counters on #{match.name} #{match.kickofftime} #{basket.name}"
          Basket.reset_counters(basket.id, :basket_items)
        end
      end
    end

    MarketPrice.counter_culture_fix_counts verbose: true
  end

  desc "run tidy up tasks"
  task tidy: :reset_counters do
    # Tasks::Db::YamlLoad::DumpDir.run
  end
end

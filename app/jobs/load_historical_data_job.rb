#
# $Id$
#
class LoadHistoricalDataJob < ApplicationJob
  queue_priority PRIORITY_LOAD_HISTORIC_DATA

  def perform(event_id, line)
    BetMarket.transaction do
      perform_with_txn(event_id, line)
    end
  end

private

  def perform_with_txn(event_id, line)
    timestamp = Time.zone.at(line.fetch(:pt) / 1000.0)

    change_list = line.fetch(:mc)
    # change_list.first

    # some markets don't have a marketType - ignore those
    def_changes = change_list.select { |x| x.dig(:marketDefinition, :marketType).present? }
    # def_changes = change_list.select { |x| x[:marketDefinition].present? }

    # if index.zero?
    #   market_def = first_mc.fetch(:marketDefinition)
    #   starttime = Time.zone.parse(market_def.fetch(:openDate))
    #   name = market_def.fetch(:eventName)
    #   hometeamname, awayteamname = name.split(" v ")
    #   hometeam = TeamName.find_by(name: hometeamname)
    #   awayteam = TeamName.find_by(name: awayteamname)
    #
    #   # break unless hometeam && awayteam
    #
    #   division = Division.active.detect { |d| d.find_match(hometeam.team, awayteam.team, starttime).present? }
    #   # break unless division
    #
    #   match = division.find_match(hometeam.team, awayteam.team, starttime)
    #   # break if match.market_prices_count.positive?
    # end

    if def_changes.any?
      market_list = def_changes.map do |mc|
        market_def = mc.fetch(:marketDefinition)
        market_def.merge(marketId: mc.fetch(:id),
                         # description: { marketTime: market_def.fetch(:marketTime),
                         #                marketType: market_def.fetch(:marketType),
                         #                turnInPlayEnabled: market_def.fetch(:turnInPlayEnabled) },
                         marketName: market_def.fetch(:name),
                         totalMatched: 0)
      end

      event = nil

      # logger.info("Market list start")
      market_list.each do |market_def|
        name = market_def.fetch(:name)
        # runners = if name.in? ["Scorecast",
        #                        "First Goalscorer",
        #                        "Shown a card?",
        #                        # "First Carded Player",
        #                        "First Goal Wincast",
        #                        "To Score a Hat-trick?",
        #                        "Last Goalscorer",
        #                        "To Score",
        #                        "To Score 2 Goals or more",
        #                        "Anytime Wincast"]
        #             []
        #           else
        #             market_def.fetch(:runners).map { |e| e.except(:sortPriority) }
        #           end
        runners = market_def.fetch(:runners).map { |e| e.except(:sortPriority) }
        starttime = Time.zone.parse(market_def.fetch(:openDate))
        event_time = (timestamp - starttime).to_i

        logger.info("Time [#{event_time / 60}:#{event_time % 60}] #{market_def.fetch(:marketId)} [#{name}] (#{market_def.fetch(:version)}) #{runners}")

        # next unless event.nil?

        name = market_def.fetch(:eventName)
        hometeamname, awayteamname = name.split(" v ")
        hometeam = TeamName.find_by(name: hometeamname)
        awayteam = TeamName.find_by(name: awayteamname)

        next unless hometeam.present? && awayteam.present?

        # event = Division.active.map { |d| d.find_match(hometeam.team, awayteam.team, starttime) }.compact.first
        division = Division.active.detect { |d| d.find_match(hometeam.team, awayteam.team, starttime) }
        event = division.find_match(hometeam.team, awayteam.team, starttime) if division.present?
      end

      if event.present?
        # market_list.select { |m| BetMarket.by_betfair_market_id(m.fetch(:marketId)).any? }
        new_markets = market_list.reject { |m| BetMarket.by_betfair_market_id(m.fetch(:marketId)).any? }
        _old_markets, new_new = new_markets.partition do |market|
          # event.bet_markets.by_betfair_market_id(market.fetch(:marketId))
          #                 .where.not(version: market.fetch(:version))
          #                 .reject { |m| m.name == market.fetch(:marketName) }.any?
          # other_versions = event.bet_markets.by_betfair_market_id(market.fetch(:marketId))
          #                 .where.not(version: market.fetch(:version))
          # other_versions.any? { |v| market.fetch(:version) > v.version }
          event.bet_markets.by_betfair_market_id(market.fetch(:marketId))
                          .where("version > ?", market.fetch(:version)).any?
        end
        # new_names.each do |new_name|
        #   o = event.bet_markets.by_betfair_market_id(market.fetch(:marketId))
        #          .where.not(version: market.fetch(:version))
        #          .reject { |m| m.name == market.fetch(:marketName) }.first!
        #   logger.info("Replacing old version #{o.betfair_marketid} #{o.name} (#{o.version}) with #{market.fetch(:marketName)}")
        #   # o.destroy_fully!
        #   o.update!(version: new_name.fetch(:version), name: new_name.fetch(:marketName))
        # end
        # (old_markets + new_new).each do |market|
        new_new.each do |market|
          old_ones = event.bet_markets
                          .where(name: market.fetch(:marketName))
                       .reject { |m| m.betfair_marketid == market.fetch(:marketId) }
          old_ones.each do |o|
            Rails.logger.warn("Destroying #{event.name} #{event.kickofftime} overlapping #{o.betfair_marketid} #{o.name} #{o.version} to make way for #{market.fetch(:marketId)} #{market.fetch(:marketName)} #{market.fetch(:version)}")
            o.destroy_fully!
          end
        end

        BetfairHandler::MarketMaker.make_markets_for_match(event, new_new).each do |bet_market|
          runner_data = market_list
                          .detect { |m| bet_market.betfair_marketid == m.fetch(:marketId) }
                          .fetch(:runners)
                          .select { |x| bet_market.asian_handicap? ? (x.key? :hc) : true }
          runners = runner_data.map { |r| r.merge(runnerName: r.fetch(:name), selectionId: r.fetch(:id), handicap: bet_market.asian_handicap? ? r.fetch(:hc) : 0) }
          to_delete = runners.select { |r| r.fetch(:status) == "REMOVED" }.map do |h|
            bet_market.market_runners.detect { |r| r.selectionId == h.fetch(:id) }
          end
          to_delete.compact.each(&:destroy_fully!)
          actives = runners.reject { |r| r.fetch(:status) == "REMOVED" }
          MakeRunnersJob.perform_now(bet_market, actives)
        end

        event.update!(betfair_event_id: event_id)
      end
    end

    other_changes = change_list.reject { |x| x.key? :marketDefinition }.select do |change|
      BetMarket.by_betfair_market_id(change.fetch(:id)).active_status.exists?
    end

    # next unless other_changes.any?

    mpt = nil

    other_changes.each do |change|
      # exchange_id, market_id = change.fetch(:id).split(".")
      # market = BetMarket.include(market_runners: :market_prices).find_by! exchange_id: exchange_id, marketid: market_id, active: true
      market = BetMarket.by_betfair_market_id(change.fetch(:id)).active_status.first!
      # TODO: Handle any detailed changes that aren't rc (runner change) based from ADVANCED download
      change.fetch(:rc, []).each do |runner_change|
        # runner = market.market_runners.find_by(selectionId: runner_change.fetch(:id), handicap: runner_change.fetch(:hc, 0))
        runner = MarketRunner.includes(market_prices: :market_price_time).find_by!(bet_market: market, selectionId: runner_change.fetch(:id), handicap: runner_change.fetch(:hc, 0))
        # It appears that we get faulty data sometimes - LTP on an asian h/cap market without a handicap (hc) value
        # This optimisation is a folly as we delete markets if the price record has too many holes in it.

        if timestamp > market.match.kickofftime
          last_time = runner.market_prices.none? ? market.time : runner.market_prices.last.market_price_time.time
          while timestamp - last_time > 3.minutes
            last_time += 3.minutes
            last_mpt = MarketPriceTime.create! time: last_time, created_at: last_time
            runner.market_prices.create! back1price: runner.market_prices.any? ? runner.market_prices.last.back1price : runner_change.fetch(:ltp), market_price_time: last_mpt
          end
        end
        mpt = MarketPriceTime.create! time: timestamp, created_at: timestamp if mpt.blank?
        runner.market_prices.create! back1price: runner_change.fetch(:ltp), market_price_time: mpt
      end
    end
  end
end

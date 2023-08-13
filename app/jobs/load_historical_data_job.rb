#
# $Id$
#
class LoadHistoricalDataJob < ApplicationJob
  queue_as :default

  # File not found can't be retried
  discard_on SystemCallError

  # IOStreams doesn't support iterators or each_with_index (boo!)
  # but it was the only library I could find that could read lines on-the-fly in ruby
  class Bzip2Iterator
    include Enumerable

    def initialize(filename)
      @filename = filename
    end

    def each(&block)
      IOStreams.path(@filename).each(&block)
    end
  end

  def perform(filename)
    match = nil
    Bzip2Iterator.new(filename).each_with_index do |raw_line, index|
      line = JSON.parse(raw_line, symbolize_names: true)

      timestamp = Time.zone.at(line.fetch(:pt) / 1000.0)

      change_list = line.fetch(:mc)
      first_mc = change_list.first

      def_changes = change_list.select { |x| x.dig(:marketDefinition, :marketType).present? }

      if index.zero?
        market_def = first_mc.fetch(:marketDefinition)
        starttime = Time.zone.parse(market_def.fetch(:openDate))
        name = market_def.fetch(:eventName)
        hometeamname, awayteamname = name.split(" v ")
        hometeam = TeamName.find_by(name: hometeamname) || break
        awayteam = TeamName.find_by(name: awayteamname) || break

        division = Division.active.detect { |d| d.find_match(hometeam.team, awayteam.team, starttime).present? }
        break unless division

        match = division.find_match(hometeam.team, awayteam.team, starttime)
        break if match.market_prices_count.positive?
      end

      if def_changes.any?
        market_list = def_changes.map do |mc|
          market_def = mc.fetch(:marketDefinition)
          market_def.merge(marketId: mc.fetch(:id),
                           description: { marketTime: market_def.fetch(:marketTime),
                                          marketType: market_def.fetch(:marketType),
                                          turnInPlayEnabled: market_def.fetch(:turnInPlayEnabled) },
                           marketName: market_def.fetch(:name),
                           totalMatched: 0)
        end

        BetfairHandler::MarketMaker.make_markets_for_match(match, market_list).each do |bet_market|
          runner_data = market_list
                          .detect { |m| bet_market.betfair_marketid == m.fetch(:marketId) }
                          .fetch(:runners)
                          .select { |x| bet_market.asian_handicap? ? (x.key? :hc) : true }
          runners = runner_data.map { |r| r.merge(runnerName: r.fetch(:name), selectionId: r.fetch(:id), handicap: bet_market.asian_handicap? ? r.fetch(:hc) : 0) }
          MakeRunnersJob.perform_now(bet_market, runners)
        end
      end

      other_changes = change_list.reject { |x| x.key? :marketDefinition }.select do |change|
        exchange_id, market_id = change.fetch(:id).split(".")
        BetMarket.exists?(exchange_id: exchange_id, marketid: market_id, active: true)
      end

      next unless other_changes.any?

      mpt = nil
      BetMarket.transaction do
        other_changes.each do |change|
          exchange_id, market_id = change.fetch(:id).split(".")
          market = BetMarket.find_by! exchange_id: exchange_id, marketid: market_id, active: true
          # TODO: Handle detailed changes that aren't rc (runner change) based from ADVANCED download
          change.fetch(:rc, []).each do |runner_change|
            runner = market.market_runners.find_by(selectionId: runner_change.fetch(:id), handicap: runner_change.fetch(:hc, 0))
            # It appears that we get faulty data sometimes - LTP on an asian h/cap market without a handicap (hc) value
            if runner && (runner.market_prices.none? || runner.market_prices.last.back1price != runner_change.fetch(:ltp))
              mpt = MarketPriceTime.create! time: timestamp, created_at: timestamp if mpt.blank?
              runner.market_prices.create! back1price: runner_change.fetch(:ltp), market_price_time: mpt
            end
          end
        end
      end
    end
  end
end

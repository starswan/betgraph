module BetfairHandler
  class MarketMaker
    class << self
      def make_single_match(division, event, markets)
        # sport = menu_path.sport
        # hometeam = sport.findTeam hometeamstr
        # awayteam = sport.findTeam awayteamstr
        if division.active
          starttime = Time.zone.parse(event.fetch(:openDate))

          match = division.matches
                          .where(name: event.fetch(:name))
                          .where("kickofftime >= ? and kickofftime <= ?", starttime.to_date, (starttime + 1.day).to_date).first
          if match.nil?
            match = make_match_from_params division, starttime, event.fetch(:name)
          end
          make_markets_for_match(match, markets).select(&:active)
        else
          []
        end
      end

      def make_match_from_params(division, kickofftime, name)
        match_type_klass = division.calendar.sport.match_type.constantize
        match_type_klass.where(name: name).where("kickofftime > ?", Time.zone.now).each(&:destroy)
        match_type_klass.create! division: division, kickofftime: kickofftime, name: name
      end

      def make_markets_for_match(match, markets)
        new_markets = markets.reject do |m|
          exchange_id, market_id = m.fetch(:marketId).split(".")
          BetMarket.find_by exchange_id: exchange_id, marketid: market_id
        end
        new_markets.map { |market| make_market_for_match match, market }
      end

    private

      def make_market_for_match(match, market)
        exchange_id, market_id = market.fetch(:marketId).split(".")
        match.bet_markets.create!(
          marketid: market_id,
          name: market.fetch(:marketName),
          markettype: market.dig(:description, :marketType),
          status: "ACTIVE",
          live_priced: market.dig(:description, :turnInPlayEnabled),
          live: market.dig(:description, :turnInPlayEnabled),
          time: market.dig(:description, :marketTime),
          exchange_id: exchange_id,
          number_of_runners: market.fetch(:runners).size,
          total_matched_amount: market.fetch(:totalMatched),
        )
      end
    end
  end
end

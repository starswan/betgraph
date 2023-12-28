module BetfairHandler
  class MarketMaker
    class << self
      def make_single_match(division, event, markets, source)
        # if division.active
        starttime = Time.zone.parse(event.fetch(:openDate))

        # match = division.matches
        #                 .where(name: event.fetch(:name))
        #                 .where("kickofftime >= ? and kickofftime <= ?", starttime.to_date, (starttime + 1.day).to_date).first
        # if match.nil?
        match = make_match_from_params division, starttime, event
        # end
        make_markets_for_match(match, markets, source).select(&:active)
        # else
        #   []
        # end
      end

      def make_match_from_params(division, kickofftime, event)
        name = event.fetch(:name)
        match_type_klass = division.calendar.sport.match_type.constantize
        existing_match = match_type_klass.find_by(division: division, kickofftime: kickofftime, name: name)
        if existing_match.present?
          existing_match
        else
          match_type_klass.where(name: name).where("kickofftime > ?", Time.zone.now).each(&:destroy)
          match_type_klass.create! division: division, kickofftime: kickofftime, name: name, betfair_event_id: event.fetch(:id)
        end
      end

      def make_markets_for_match(match, markets, source)
        new_markets = markets.reject { |m| BetMarket.by_betfair_market_id(m.fetch(:marketId)).any? }
        # new_markets.each do |market|
        #   old_ones = match.bet_markets.by_betfair_market_id(market.fetch(:marketId))
        #                   .where.not(version: market.fetch(:version))
        #                   .reject { |m| m.name == market.fetch(:marketName) }
        #   old_ones.each do |o|
        #     Rails.logger.info("Replacing old version #{o.betfair_marketid} #{o.name} (#{o.version}) with #{market.fetch(:marketName)}")
        #     o.destroy_fully!
        #   end
        # end
        new_markets.map do |market|
          # old_ones = match.bet_markets
          #                 .where(name: market.fetch(:marketName))
          #              .reject { |m| m.betfair_marketid == market.fetch(:marketId) }
          # old_ones.each do |o|
          #   Rails.logger.info("Destroying overlap #{o.betfair_marketid} #{o.name}")
          #   o.destroy_fully!
          # end
          make_market_for_match match, market, source
        end
      end

    private

      def make_market_for_match(match, market, source)
        exchange_id, market_id = market.fetch(:marketId).split(".")
        Rails.logger.debug("#{market.fetch(:marketTime)} #{match.name} Creating #{market.fetch(:marketId)} #{market.fetch(:marketName)}")
        match.bet_markets.create!(
          marketid: market_id,
          name: market.fetch(:marketName),
          price_source: source,
          version: market.fetch(:version, 0),
          markettype: market.fetch(:marketType),
          status: market.fetch(:status, "ACTIVE"),
          live_priced: market.fetch(:turnInPlayEnabled),
          live: market.fetch(:turnInPlayEnabled),
          time: market.fetch(:marketTime),
          exchange_id: exchange_id,
          number_of_runners: market.fetch(:runners).size,
          total_matched_amount: market.fetch(:totalMatched),
        )
      end
    end
  end
end

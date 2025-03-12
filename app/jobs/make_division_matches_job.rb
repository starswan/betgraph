# frozen_string_literal: true

#
# $Id$
#
class MakeDivisionMatchesJob < BetfairJob
  queue_priority PRIORITY_MAKE_MATCHES

  def perform(competition)
    division = competition.division
    event_list = bc.get_events_for_competition(id: competition.betfair_id)
    # This needs splitting - it takes too long on a Pi and stops important price collection
    make_matches(division, event_list).each do |bet_market|
      runner_detail = bc.getMarketDetail(bet_market.exchange_id, bet_market.marketid)
      MakeRunnersJob.perform_later bet_market, runner_detail.fetch(:runners)
    end
  end

  def make_matches(division, event_list)
    event_list.flat_map do |event|
      name = event.fetch(:name)
      markets = bc.get_markets_for_event(event)
                  .map { |m| m.merge(m.fetch(:description).except(:description)) }
      a_vs_b = name.index(" v ")
      a_at_b = name.index(" @ ")
      if a_vs_b
        make_single_match division, event, markets, "RestAPI"
      elsif a_at_b
        make_single_match division, event, markets, "RestAPI"
      elsif name.ends_with?("Grand Prix")
        make_single_match division, event, markets, "RestAPI"
      else
        []
      end
    end
  end

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
      match_type_klass.where(name: name).where("kickofftime > ?", Time.zone.now).find_each(&:destroy)
      match_type_klass.create! division: division, kickofftime: kickofftime, name: name, betfair_event_id: event.fetch(:id)
    end
  end

  # This is called by DownloadHistoricalDataFileJob
  def make_markets_for_match(match, markets, source)
    new_markets = markets.reject { |m| BetMarket.by_betfair_market_id(m.fetch(:marketId)).any? }
    # new_markets.each do |market|
    #   old_ones = match.bet_markets.by_betfair_market_id(market.fetch(:marketId))
    #                   .where.not(version: market.fetch(:version))
    #                   .reject { |m| m.name == market.fetch(:marketName) }
    #   old_ones.each do |o|
    #     Rails.logger.info("Replacing old version #{o.betfair_marketid} #{o.name} (#{o.version}) with #{market.fetch(:marketName)}")
    #     o.really_destroy!
    #   end
    # end
    new_markets.map do |market|
      # old_ones = match.bet_markets
      #                 .where(name: market.fetch(:marketName))
      #              .reject { |m| m.betfair_marketid == market.fetch(:marketId) }
      # old_ones.each do |o|
      #   Rails.logger.info("Destroying overlap #{o.betfair_marketid} #{o.name}")
      #   o.really_destroy!
      # end
      make_market_for_match match, market, source
    end
  end

private

  def make_market_for_match(match, market, source)
    exchange_id, market_id = market.fetch(:marketId).split(".")
    Rails.logger.info("#{market.fetch(:marketTime)} #{match.name} Creating #{market.fetch(:marketId)} #{market.fetch(:marketName)}")
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

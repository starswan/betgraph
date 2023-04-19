# frozen_string_literal: true

#
# $Id$
#
class MakeMatchesJob < BetfairJob
  queue_priority PRIORITY_MAKE_MATCHES

  def perform(sport)
    sport.competitions.active.each do |competition|
      make_matches(competition) do |market|
        MakeRunnersJob.perform_later market
      end
    end
  end

  def make_matches(competition)
    # emptyArrayHash = Hash.new { |h, i| h[i] = [] }
    # marketsByMenuPath = market_list.each_with_object(emptyArrayHash) { |market, hash| hash[market.menuPath] << market }
    # events_by_name = event_list.index_by { |v| v.fetch(:name)}
    # This looks through all the active menu paths, and tries to create a match based on
    # whether it looks like it might represent a match/event - this is actually sport-specific
    # (Note that A v B is soccer, Tennis, Cricket etc, A @ B is Baseball, American Football and
    # ending in 'GP' is Motor Sport(F1/Super Bikes))
    # sport.menu_paths.active.select { |mp| mp.name[-1].in? events_by_name.keys }.each do |menu_path|
    # markets = marketsByMenuPath[menu_path.name]
    event_list = bc.get_events_for_competition(id: competition.betfair_id)
    event_list.each do |event|
      # name = menu_path.name[-1]
      name = event.fetch(:name)
      markets = bc.get_markets_for_event(event)
      a_vs_b = name.index(" v ")
      a_at_b = name.index(" @ ")
      if a_vs_b
        markets = make_single_match competition, event, markets
        markets.each { |m| yield m }
      elsif a_at_b
        markets = make_single_match competition, event, markets
        markets.each { |m| yield m }
      elsif name.ends_with?("Grand Prix")
        markets = make_single_match competition, event, markets
        markets.each { |m| yield m }
      end
    end
  end

  def make_single_match(competition, event, markets)
    # sport = menu_path.sport
    # hometeam = sport.findTeam hometeamstr
    # awayteam = sport.findTeam awayteamstr
    division = competition.division
    if division.active
      # first_market = markets.first
      logger.debug "make_single_match #{event.inspect} #{competition}"
      starttime = Time.zone.parse(event.fetch(:openDate))

      match = division.matches
        .where(name: event.fetch(:name))
        .where("kickofftime >= ? and kickofftime <= ?", starttime.to_date, (starttime + 1.day).to_date).first
      if match.nil?
        match = make_match_from_params division, starttime, event.fetch(:name)
      end
      make_markets_for_match(match, markets)
    else
      []
    end
  end

  def make_match_from_params(division, kickofftime, name)
    match_type_klass = division.calendar.sport.match_type.constantize
    match_type_klass.where(name: name).where("kickofftime > ?", Time.zone.now).each(&:destroy)
    match_type_klass.create! division: division, kickofftime: kickofftime, name: name
  end

  # def make_event_and_markets(competition, markets, venuename)
  #   # sport = menu_path.sport
  #   division = competition.division
  #   starttime = markets.first.marketTime
  #   return [] if division.matches.find_by(kickofftime: starttime, name: menu_path.name[-1])
  #
  #   venue = sport.findTeam venuename
  #   match = division.matches.create! kickofftime: starttime,
  #                                    type: sport.match_type,
  #                                    venue: venue,
  #                                    name: menu_path.name[-1]
  #   winnerMarket = markets.find { |m| m.name == "Winner" }
  #   # winnerMarket.getDetail do |detail|
  #   #   detail.runners.each do |runner|
  #   #     match.teams << sport.findTeam(runner.name)
  #   #   end
  #   # end
  #   winnerMarket.runners.each do |runner|
  #     match.teams << sport.findTeam(runner.name)
  #   end
  #   # make_markets_for_match(match, markets, menu_path).each do |market|
  #   #   yield market
  #   # end
  #   make_markets_for_match(match, markets)
  # end

  # menu_path.division is hopefully the location for the match
  # between these two teams. May have to walk the menupath tree to
  # find a division - hopefully division_ids should cascade from parents
  # down to children.
  def find_division(menu_path)
    menu_path = menu_path.parent_path until menu_path.division
    menu_path.division
  end

private

  def make_markets_for_match(match, markets)
    new_markets = markets.reject do |m|
      exchange_id, market_id = m.fetch(:marketId).split(".")
      BetMarket.find_by exchange_id: exchange_id, marketid: market_id
    end
    new_markets.map { |market|
      make_market_for_match match, market
      # BetMarket.find(parsed_market.market_id)
    }.select(&:active)
  end

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

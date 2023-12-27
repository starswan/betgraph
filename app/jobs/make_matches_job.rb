# frozen_string_literal: true

#
# $Id$
#
class MakeMatchesJob < BetfairJob
  queue_priority PRIORITY_MAKE_MATCHES

  def perform(sport)
    sport.competitions.active.each do |competition|
      # emptyArrayHash = Hash.new { |h, i| h[i] = [] }
      # marketsByMenuPath = market_list.each_with_object(emptyArrayHash) { |market, hash| hash[market.menuPath] << market }
      # events_by_name = event_list.index_by { |v| v.fetch(:name)}
      # This looks through all the active menu paths, and tries to create a match based on
      # whether it looks like it might represent a match/event - this is actually sport-specific
      # (Note that A v B is soccer, Tennis, Cricket etc, A @ B is Baseball, American Football and
      # ending in 'GP' is Motor Sport(F1/Super Bikes))
      # sport.menu_paths.active.select { |mp| mp.name[-1].in? events_by_name.keys }.each do |menu_path|
      # markets = marketsByMenuPath[menu_path.name]
      division = competition.division
      event_list = bc.get_events_for_competition(id: competition.betfair_id)
      make_matches(division, event_list).each do |bet_market|
        runner_detail = bc.getMarketDetail(bet_market.exchange_id, bet_market.marketid)
        MakeRunnersJob.perform_later bet_market, runner_detail.fetch(:runners)
      end
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
        BetfairHandler::MarketMaker.make_single_match division, event, markets, 'RestAPI'
      elsif a_at_b
        BetfairHandler::MarketMaker.make_single_match division, event, markets, 'RestAPI'
      elsif name.ends_with?("Grand Prix")
        BetfairHandler::MarketMaker.make_single_match division, event, markets, 'RestAPI'
      else
        []
      end
    end
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
end

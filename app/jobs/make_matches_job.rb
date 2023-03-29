# frozen_string_literal: true

#
# $Id$
#
class MakeMatchesJob < BetfairJob
  queue_priority PRIORITY_MAKE_MATCHES

  def perform(sport)
    make_matches(sport, bc.getActiveMarkets) do |market|
      MakeRunnersJob.perform_later market
    end
  end

  def make_matches(sport, market_list)
    emptyArrayHash = Hash.new { |h, i| h[i] = [] }
    marketsByMenuPath = market_list.each_with_object(emptyArrayHash) { |market, hash| hash[market.menuPath] << market }
    # This looks through all the active menu paths, and tries to create a match based on
    # whether it looks like it might represent a match/event - this is actually sport-specific
    # (Note that A v B is soccer, Tennis, Cricket etc, A @ B is Baseball, American Football and
    # ending in 'GP' is Motor Sport(F1/Super Bikes))
    sport.menu_paths.active.reject { |mp| marketsByMenuPath[mp.name].empty? }.each do |menu_path|
      markets = marketsByMenuPath[menu_path.name]
      name = menu_path.name[-1]
      a_vs_b = name.index(" v ")
      a_at_b = name.index(" @ ")
      if a_vs_b
        markets = make_single_match menu_path, markets, name[0, a_vs_b], name[a_vs_b + 3, name.size - 1]
        markets.each { |m| yield m }
      elsif a_at_b
        markets = make_single_match menu_path, markets, name[a_at_b + 3, name.size - 1], name[0, a_at_b]
        markets.each { |m| yield m }
      elsif name.ends_with?("GP")
        markets = make_event_and_markets menu_path, markets, name
        markets.each { |m| yield m }
      end
    end
  end

  def make_single_match(menu_path, markets, _hometeamstr, _awayteamstr)
    # sport = menu_path.sport
    # hometeam = sport.findTeam hometeamstr
    # awayteam = sport.findTeam awayteamstr
    division = find_division menu_path
    if division.active
      first_market = markets.first
      logger.debug "make_single_match #{first_market.inspect} #{menu_path.name[-1]}"
      starttime = first_market.marketTime

      match = division.matches
        .where(name: menu_path.name[-1])
        .where("kickofftime >= ? and kickofftime <= ?", starttime.to_date, (starttime + 1.day).to_date).first
      # match = division.matches.create! :kickofftime => starttime,
      #                                 :name => menu_path.name[-1],
      #                                 :type => sport.match_type,
      #                                 :venue => hometeam
      #                                 #:hometeam => hometeam,
      #                                 #:awayteam => awayteam
      if match.nil?
        parsed_match = railsclient.makeMatch division,
                                             kickofftime: starttime,
                                             name: menu_path.name[-1]
        match = Match.find parsed_match.id
        # match.teams << hometeam
        # match.teams << awayteam
      end
      begin
        # make_markets_for_match(match, markets, menu_path).each do |market|
        #   yield market
        # end
        make_markets_for_match(match, markets, menu_path)
      rescue Exception => e
        logger.error "make_single_match error: #{e.inspect}"
        railsclient.destroyMatch match
        raise
      end
    else
      []
    end
  end

  def make_event_and_markets(menu_path, markets, venuename)
    sport = menu_path.sport
    division = find_division menu_path
    starttime = markets.first.marketTime
    return [] if division.matches.find_by(kickofftime: starttime, name: menu_path.name[-1])

    venue = sport.findTeam venuename
    match = division.matches.create! kickofftime: starttime,
                                     type: sport.match_type,
                                     venue: venue,
                                     name: menu_path.name[-1]
    winnerMarket = markets.find { |m| m.name == "Winner" }
    # winnerMarket.getDetail do |detail|
    #   detail.runners.each do |runner|
    #     match.teams << sport.findTeam(runner.name)
    #   end
    # end
    winnerMarket.runners.each do |runner|
      match.teams << sport.findTeam(runner.name)
    end
    # make_markets_for_match(match, markets, menu_path).each do |market|
    #   yield market
    # end
    make_markets_for_match(match, markets, menu_path)
  end

  # menu_path.division is hopefully the location for the match
  # between these two teams. May have to walk the menupath tree to
  # find a division - hopefully division_ids should cascade from parents
  # down to children.
  def find_division(menu_path)
    menu_path = menu_path.parent_path until menu_path.division
    menu_path.division
  end

private

  def make_markets_for_match(match, markets, _menu_path)
    markets.reject { |m| BetMarket.find_by marketid: m.marketId }.map { |market|
      parsed_market = railsclient.makeMarket match, market
      # @stalker.make_runners parsed_market.market_id if parsed_market.active
      # yield BetMarket.find(parsed_market.market_id) if parsed_market.active
      #
      BetMarket.find(parsed_market.market_id)
    }.select(&:active)
  end
end

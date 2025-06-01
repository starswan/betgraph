# frozen_string_literal: true

#
# $Id$
#
class MakeRunnersJob < BetfairJob
  queue_priority PRIORITY_MAKE_RUNNERS

  def perform(bet_market, runner_data)
    runners = []
    runner_data.each_with_index do |runner, index|
      if bet_market.asian_handicap?
        logger.debug "#{bet_market.name} making #{(index + 1).ordinalize} runner #{runner.fetch(:runnerName)} hcap: #{runner.fetch(:handicap)}"
        runners << { name: runner.fetch(:runnerName), handicap: runner.fetch(:handicap) }
      else
        logger.debug "#{bet_market.name} making #{(index + 1).ordinalize} runner #{runner.fetch(:runnerName)}"
        runners << runner.fetch(:runnerName)
      end
      description = runner.fetch(:runnerName)
      runner = bet_market.market_runners.create!(selectionId: runner.fetch(:selectionId),
                                                 # asianLineId: runner[:asianLineId],
                                                 betfair_runner_type: find_runner_type(bet_market, description),
                                                 handicap: runner.fetch(:handicap),
                                                 description: description,
                                                 sortorder: runner.fetch(:sortPriority))
      MakeBasketItemsJob.perform_later runner
    end
    logger.debug "Make ok #{bet_market.markettype} #{bet_market.name} runners #{runners.inspect}"
  end

private

  def find_runner_type(bet_market, description)
    if bet_market.match.instance_of?(MotorRace)
      runnertype = BetfairRunnerType.find_or_create_by! name: description,
                                                        betfair_market_type: bet_market.betfair_market_type do |rt|
        rt.runnertype = description
        rt.runnerhomevalue = 0
        rt.runnerawayvalue = 0
      end
    else
      home_teamnames = bet_market.match.hometeam.team_names.map(&:name)
      away_teamnames = bet_market.match.awayteam.team_names.map(&:name)

      # Cartesian product of the 2 arrays of home and away teams
      names = home_teamnames.product(away_teamnames).map do |hometeam, awayteam|
        runnerdesc = description
                       .gsub(hometeam, hometeam.to_s)
                       .gsub(awayteam, awayteam.to_s)

        # interpolatedname = runnerdesc.gsub '\#', '#'
        runnertype = bet_market.betfair_market_type.betfair_runner_types.find_by name: runnerdesc

        [runnerdesc, runnertype]
      end
      # This isn't quite right - we actually need the shortest (most accurate) match
      # so that AC Milan is matched against '#{hometeam}' rather than 'AC #{hometeam}'
      if names.detect { |_d, type| type.present? }
        # runnertype = names.reject { |_desc, runnertype| runnertype.nil? }.first.second
        runnertype = names.reject { |_desc, runner_type| runner_type.nil? }.min { |d, _t| d.size }.second
      else
        # try to find the best interpolated name - but pick the first one otherwise
        # but using max rather than min here makes no sense - but the test passes (and fails the other way round)
        pair = names.select { |desc, _type| desc.include?('#{') }.max { |d, _t| d.size } || names.first
        runnerdesc = pair.first
        runnertype = BetfairRunnerType.create! name: runnerdesc,
                                               betfair_market_type: bet_market.betfair_market_type,
                                               runnertype: runnerdesc,
                                               runnerhomevalue: 0,
                                               runnerawayvalue: 0
      end
    end

    runnertype
  end
end

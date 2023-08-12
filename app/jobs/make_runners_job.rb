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
      runner = bet_market.market_runners.create!(selectionId: runner.fetch(:selectionId),
                                                 # asianLineId: runner[:asianLineId],
                                                 handicap: runner.fetch(:handicap),
                                                 description: runner.fetch(:runnerName),
                                                 sortorder: runner.fetch(:sortPriority))
      MakeBasketItemsJob.perform_later runner
    end
    logger.debug "Make ok #{bet_market.markettype} #{bet_market.name} runners #{runners.inspect}"
  end
end

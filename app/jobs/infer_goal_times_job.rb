# frozen_string_literal: true

class InferGoalTimesJob < ApplicationJob
  queue_priority PRIORITY_INFER_GOAL_TIMES

  # hash of scores to time at which prices unavailable
  class StopTimes
    def initialize(market)
      @stoptimes = market.market_runners
                         .map { |mr| mr.market_prices.reverse_each.detect { |mp| mp.lay1price.present? } }
                         .compact
                         .map { |x|
        [x.market_runner.description,
         (x.market_price_time.created_at - x.market_runner.bet_market.match.kickofftime).to_i]
      }.to_h
    end

    def has_key?(homescore, awayscore)
      @stoptimes.key? key(homescore, awayscore)
    end

    def fetch(homescore, awayscore)
      @stoptimes[key(homescore, awayscore)]
    end

  private

    # The key is market_runner.description which is always (we hope) this
    # as this should be the CorrectScore market
    def key(homescore, awayscore)
      "#{homescore} - #{awayscore}"
    end
  end

  def perform(match)
    BetMarket.transaction do
      soccer = Sport.find_by!(name: "Soccer")
      market_type = BetfairMarketType.find_by!(sport_id: soccer.id, name: "Correct Score")
      # This is harmless if the match doesn't have a Correct Score for some reason.
      market = match.bet_markets
                   .includes(market_runners: :market_prices, match: :result)
                   .where(betfair_market_type_id: market_type.id)
                   .first
      return unless market

      stoptimes = StopTimes.new(market)
      homescore = 0
      awayscore = 0
      while stoptimes.has_key?(homescore, awayscore) &&
          !scores_equal(homescore, awayscore, match)
        first_goal = stoptimes.fetch(homescore, awayscore)
        if stoptimes.fetch(homescore, awayscore + 1) == first_goal &&
            stoptimes.fetch(homescore + 1, awayscore) != first_goal
          homescore += 1
          match.scorers.create! goaltime: first_goal, name: "#{match.hometeam.teamname} Player", team: match.hometeam
        else
          awayscore += 1
          match.scorers.create! goaltime: first_goal, name: "#{match.awayteam.teamname} Player", team: match.awayteam
        end
      end
      if scores_equal(homescore, awayscore, match)
        logger.info "Success #{match.kickofftime} #{match.name} #{homescore}-#{awayscore}"
      else
        logger.warn "Oh Noes #{match.kickofftime.to_date} [#{match.id}] #{match.name} predicted #{homescore}-#{awayscore} actual #{market.match.result.homescore}-#{market.match.result.awayscore}"
        raise ActiveRecord::Rollback
      end
      # market.market_price_times.each do |mpt|
      #   mpt.market_prices.detect do |mp|
      #     rt = mp.market_runner.betfair_runner_type
      #     rt.runnerhomevalue == 0 && rt.runnerawayvalue == 0
      #   end
      # end
    end
  rescue ActiveRecord::Rollback
    #   shucks - transaction aborted
  end

private

  def scores_equal(homescore, awayscore, match)
    [homescore, awayscore] == [match.result.homescore, match.result.awayscore]
  end
end

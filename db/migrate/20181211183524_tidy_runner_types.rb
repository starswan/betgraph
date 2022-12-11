# frozen_string_literal: true

#
# $Id$
#
class TidyRunnerTypes < ActiveRecord::Migration[5.1]
  def up
    runner_types = Sport.find_by(name: "Soccer").betfair_market_types.map(&:betfair_runner_types).flatten
    count = runner_types.size
    runner_types.reject { |rt|
      scores = (0..7).to_a.product((0..7).to_a).map { |a, b| "#{a} - #{b}" }
      handicaps = (1..3).to_a.product(['#{hometeam}', '#{awayteam}']).map { |h, team|
        ["#{team} +#{h}", "#{team} -#{h}"]
      }.flatten
      stuff = [
        '#{hometeam}', '#{awayteam}', "Odd", "Even",
        "The Draw", "Yes", "No",
        "Any Other Home Win", "Any Other Away Win", "Any Other Draw", "Any Unquoted", "Any Unquoted ",
        "Any unquoted", "Draw"
      ]
      over_unders = (0..6).map { |n| ["Under #{n}.5 Goals", "Over #{n}.5 Goals"] }.flatten
      n_or_more_goals = (1..7).map { |n| "#{n} goals or more" }
      (scores + handicaps + stuff + over_unders + n_or_more_goals).include?(rt.name)
    }.each_with_index do |brt, index|
      say_with_time "#{index}/#{count} [#{brt.name}] (#{brt.market_runners.count})" do
        # Force a recalculate of BetfairRunnerType after bugfix
        brt.market_runners.each do |runner|
          runner.update asianLineId: runner.asianLineId
        end
      end
    end
    BetfairRunnerType.select { |b| b.market_runners.count == 0 } .map(&:destroy)
  end
end

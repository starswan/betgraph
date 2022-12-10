# frozen_string_literal: true

#
# $Id$
#
class InferAllGoalTimesJob < ApplicationJob
  queue_priority PRIORITY_INFER_GOAL_TIMES

  class << self
    def score_too_high(match)
      match.result.homescore > 3 && match.result.awayscore > 3
    end
  end

  def perform
    SoccerMatch.includes(:result, :scorers).where("created_at > ?", Date.today - 1.month)
      .find_each
      .reject { |m|
      m.bet_markets_count == 0 ||
        m.result.nil? ||
        m.scorers_filled_in? ||
        self.class.score_too_high(m)
    }.each do |sm|
      InferGoalTimesJob.perform_later(sm)
    end
  end
end

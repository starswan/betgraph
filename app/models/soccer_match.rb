# frozen_string_literal: true

#
# $Id$
#
class SoccerMatch < AvsBMatch
  has_many :scorers, -> { order(:goaltime) }, foreign_key: :match_id, dependent: :destroy

  # scotland doesn't behave like this, so just exclude for now (and Greece apparently - but don't understand why)
  validates :name, uniqueness: { case_sensitive: true, scope: [:division_id, :season_id, :deleted_at], unless: -> { division.scottish? } }

  def score_at(time)
    seconds = time - kickofftime
    if seconds > 45.minutes
      seconds -= 15.minutes
    end
    [scorers.count { |s| s.team == hometeam && s.goaltime <= seconds },
     scorers.count { |s| s.team == awayteam && s.goaltime <= seconds }]
  end

  # Try and guess the final match score based on data from the Correct Score market
  def estimated_score
    if result
      [result.homescore, result.awayscore]
    else
      winner = bet_markets.find_by(name: "Correct Score").winners.first
      [winner.betfair_runner_type.runnerhomevalue.to_i, winner.betfair_runner_type.runnerawayvalue.to_i]
    end
  end

  def homescore
    result ? result.homescore : nil
  end

  def awayscore
    result ? result.awayscore : nil
  end

  # if we know exactly when match started, use that otherwise used advertised time
  def match_start_time
    actual_start_time || kickofftime
  end

  # of course this is a little tricky when the half can last more than 45 minutes
  def actual_match_time(offset_in_minutes)
    match_start_time + offset_in_minutes * 60 + (offset_in_minutes > 45 ? half_time_duration : 0)
  end

  def scorers_filled_in?
    result.present? && result.homescore == homescorercount && result.awayscore == awayscorercount
  end
end

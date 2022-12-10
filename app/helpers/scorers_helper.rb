# frozen_string_literal: true

#
# $Id$
#
module ScorersHelper
  def description(match)
    match.hometeam.name + " v " + match.awayteam.name + " " + l(match.kickofftime)
  end

  def scorer_goal_time(scorer)
    format_goaltime(scorer.goaltime) + (scorer.penalty ? "(p)" : "") + (scorer.owngoal ? "(og)" : "")
  end

  def format_goaltime(time)
    # subtract 15 mins if in definitely in second half
    time -= 15 * 60 if time > 55 * 60
    mins = "%02d" % (time / 60)
    secs = "%02d" % (time % 60)
    "#{mins}:#{secs}"
  end
end

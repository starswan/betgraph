# frozen_string_literal: true

#
# $Id$
#
module ResultsHelper
  def format_result(match)
    if match.result
      if match.result.homescore + match.result.awayscore == 0
        "0-0"
      elsif match.result.homescore + match.result.awayscore == match.scorers.size
        homescore, awayscore = 0, 0
        match.scorers.map { |s|
          if s.team_id == match.hometeam_id
            homescore += 1
          else
            awayscore += 1
          end
          "#{homescore}-#{awayscore}(#{format_goaltime(s.goaltime)})"
        }.join(", ")
      elsif match.result.half_time_home_score.blank?
        "#{match.result.homescore}-#{match.result.awayscore}"
      else
        "#{match.result.homescore}-#{match.result.awayscore} HT:[#{match.result.half_time_home_score}-#{match.result.half_time_away_score}]"
      end
    end
  end
end

# frozen_string_literal: true

class AatBMatch < TwoPlayerMatch
  before_create do |match|
    hometeam, awayteam = match.name.split(" @ ")

    match.hometeam = match.division.calendar.sport.findTeam hometeam
    match.awayteam = match.division.calendar.sport.findTeam awayteam
  end
end

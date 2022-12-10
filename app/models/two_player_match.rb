# frozen_string_literal: true

#
# $Id$
#
class TwoPlayerMatch < Match
  delegate :id, prefix: true, to: :hometeam
  delegate :id, prefix: true, to: :awayteam

  before_create do |match|
    hometeam, awayteam = match.name.split(" v ")

    match.hometeam = match.division.calendar.sport.findTeam hometeam
    match.awayteam = match.division.calendar.sport.findTeam awayteam
  end

  def hometeamname
    hometeam.name
  end

  def awayteamname
    awayteam.name
  end

  def hometeam
    teams.detect { |t| t.id == venue_id }
  end

  def awayteam
    teams.detect { |t| t.id != venue_id }
  end

  def hometeam=(team)
    self.venue = team
    teams << team
  end

  def hometeam_id=(team_id)
    self.venue_id = team_id
    teams << Team.find(team_id)
  end

  def awayteam=(team)
    teams << team
  end

  def awayteam_id=(team_id)
    teams << Team.find(team_id)
  end
end

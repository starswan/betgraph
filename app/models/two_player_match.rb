# frozen_string_literal: true

#
# $Id$
#
class TwoPlayerMatch < Match
  delegate :id, prefix: true, to: :hometeam
  delegate :id, prefix: true, to: :awayteam

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
    self.teams = teams.to_a.delete_if { |t| t.id == venue_id } + [team]
    self.venue = team
  end

  def awayteam=(team)
    self.teams = teams.to_a.delete_if { |t| t.id != venue_id } + [team]
  end
end

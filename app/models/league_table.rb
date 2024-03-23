# frozen_string_literal: true

#
# $Id$
#
class LeagueTable
  attr_reader :rows

  def initialize(matches)
    teams = matches.map(&:teams).flatten.uniq
    @rows = teams.map { |team| LeagueTableRow.new(team, matches.select { |m| m.teams.include?(team) }) }.sort_by(&:ordering)
  end

  def position(team)
    position_pair = rows.map.with_index { |m, i| [m.team, i + 1] }.detect { |pair| pair.first == team }
    if position_pair
      position_pair.second
    else
      0
    end
  end
end

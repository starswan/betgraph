# frozen_string_literal: true

#
# $Id$
#
module SoccerMatchesHelper
  def match_name(match)
    match.hometeam.name + " v " + match.awayteam.name
  end
end

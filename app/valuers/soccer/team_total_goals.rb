# frozen_string_literal: true

#
# $Id$
#
module Soccer
  #
  # This would be simply Poisson distributed, but there are typically no prices for these
  # types of market during the game. I think they get re-opened at half-time.
  #
  class TeamTotalGoals < FullTimeValuer
    def value_with_handicap(_homevalue, _awayvalue, _homescore, _awayscore, _handicap)
      0
    end
  end
end

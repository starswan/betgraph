# frozen_string_literal: true

#
# $Id$
#
module Soccer
  class MatchOdds < FullTimeValuer
    #
    # If homescore > awayscore, return home
    # If homescore == awayscore, return draw
    # If homescore < awayscore, return away
    # Simples!
    #
    def value(homevalue, awayvalue, homescore, awayscore)
      winner = homevalue > 0 ? homescore > awayscore : awayvalue > 0 ? awayscore > homescore : homescore == awayscore
      winner ? 1 : -1
    end
  end
end

# frozen_string_literal: true

#
# $Id$
#
module Soccer
  # This market is a 'push' if the game is a draw
  class DrawNoBet < FullTimeValuer
    def value(homevalue, awayvalue, homescore, awayscore)
      if homescore == awayscore
        0
      elsif homescore > awayscore
        homevalue.to_i > 0 ? 1 : -1
      else
        awayvalue.to_i > 0 ? 1 : -1
      end
    end
  end
end

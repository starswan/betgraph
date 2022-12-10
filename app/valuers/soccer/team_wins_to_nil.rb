# frozen_string_literal: true

#
# $Id$
#

module Soccer
  class TeamWinsToNil < FullTimeValuer
    def value(homevalue, awayvalue, homescore, awayscore)
      win = (homevalue != 0) ? homevalue > 0 ? ((homescore > 0) && (awayscore == 0)) : ((homescore == 0) || (awayscore > 0)) : awayvalue > 0 ? ((awayscore > 0) && (homescore == 0)) : ((awayscore == 0) || (homescore > 0))
      win ? 1 : -1
    end
  end
end

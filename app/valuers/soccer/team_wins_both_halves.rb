# frozen_string_literal: true

#
# $Id$
#
module Soccer
  class TeamWinsBothHalves < FullTimeValuer
    def value(_homevalue, _awayvalue, _homescore, _awayscore)
      0
    end
  end
end

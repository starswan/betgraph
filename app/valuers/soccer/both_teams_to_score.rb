# frozen_string_literal: true

#
# $Id$
#
module Soccer
  class BothTeamsToScore < FullTimeValuer
    def value(homevalue, _awayvalue, homescore, awayscore)
      both_scored = (homescore > 0 && awayscore > 0)
      if homevalue > 0
        both_scored ? 1 : -1
      else
        both_scored ? -1 : 1
      end
    end

    def probability(_homevalue, _awayvalue, homescore, awayscore, phome, paway)
      if (homescore > 0) && (awayscore > 0)
        1
      elsif homescore > 0
        paway
      elsif awayscore > 0
        phome
      else
        1 - (1 - phome) * (1 - paway)
      end
    end
  end
end

# frozen_string_literal: true

#
# $Id$
#
module Soccer
  class TotalGoals < FullTimeValuer
    def value_with_handicap(h, a, hs, as, handicap)
      value h, a, hs, as, handicap
    end

    def value(_homevalue, _awayvalue, homescore, awayscore, handicap)
      homescore + awayscore + handicap >= 0 ? 1 : -1
    end
  end
end

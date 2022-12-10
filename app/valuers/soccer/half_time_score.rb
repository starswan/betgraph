# frozen_string_literal: true

#
# $Id$
#
module Soccer
  class HalfTimeScore < HalfTimeValuer
    def initialize
      @max = 2
      @min = 0
    end

    def value(homevalue, awayvalue, homescore, awayscore)
      winner?(homevalue, awayvalue, homescore, awayscore) ? 1 : -1
    end

  private

    def winner?(homevalue, awayvalue, homescore, awayscore)
      if (homevalue >= 0 && homevalue <= @max) && (awayvalue >= 0 && awayvalue <= @max)
        (homevalue == homescore && awayvalue == awayscore)
      else
        (homescore > @max || awayscore > @max)
      end
    end
  end
end

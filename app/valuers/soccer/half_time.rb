#
# $Id$
#
module Soccer
  class HalfTime < HalfTimeValuer
    def value(homevalue, awayvalue, homescore, awayscore)
      winner = homevalue > 0 ? homescore > awayscore : awayvalue > 0 ? awayscore > homescore : homescore == awayscore
      winner ? 1 : -1
    end
  end
end

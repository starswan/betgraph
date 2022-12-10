# frozen_string_literal: true

#
# $Id$
#
module Soccer
  # not really sure about this market, as it's pretty chaotic - in the money 1 minute, out of it the next
  class OddOrEven < FullTimeValuer
    def value(homevalue, _awayvalue, homescore, awayscore)
      (homescore.to_i + awayscore.to_i) % 2 == homevalue.to_i ? 1 : -1
    end
  end
end

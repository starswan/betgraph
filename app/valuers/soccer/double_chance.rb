# frozen_string_literal: true

#
# $Id$
#
module Soccer
  class DoubleChance < FullTimeValuer
    def value(homevalue, awayvalue, homescore, awayscore)
      if homevalue < 0
        (homescore <= awayscore) ? 1 : -1
      elsif awayvalue < 0
        (homescore >= awayscore) ? 1 : -1
      else
        (homescore != awayscore) ? 1 : -1
      end
    end
  end
end

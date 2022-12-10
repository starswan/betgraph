# frozen_string_literal: true

#
# $Id$
#
module Soccer
  class TeamCleanSheet < FullTimeValuer
    def value(homevalue, awayvalue, homescore, awayscore)
      winner(homevalue, awayvalue, homescore, awayscore) ? 1 : -1
    end

  private

    def winner(homevalue, awayvalue, homescore, awayscore)
      if homevalue > 0
        awayscore == 0
      elsif homevalue < 0
        awayscore > 0
      elsif awayvalue > 0
        homescore == 0
      else
        homescore > 0
      end
    end
  end
end

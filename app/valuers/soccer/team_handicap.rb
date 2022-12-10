# frozen_string_literal: true

#
# $Id$
#
module Soccer
  class TeamHandicap < FullTimeValuer
    def value(homevalue, awayvalue, homescore, awayscore)
      hometotal = homescore + homevalue
      if homevalue == awayvalue
        # draw value for HT += value
        hometotal == awayscore ? 1 : -1
      else
        awaytotal = awayscore + awayvalue
        if homevalue != 0
          hometotal > awaytotal ? 1 : -1
        elsif awayvalue != 0
          awaytotal > hometotal ? 1 : -1
        end
      end
    end
  end
end

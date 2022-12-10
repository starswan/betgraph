# frozen_string_literal: true

#
# $Id$
#
module Soccer
  class AsianHandicap < FullTimeValuer
    # homevalue == 1 means runner is home team, awayvalue == 1 indicates runner is awayteam
    # handicap is in units of half a goal, so 0.75 handicap means half bet at 0.5 and half at 1.0
    def value_with_handicap(homevalue, _awayvalue, homescore, awayscore, handicap)
      h4 = (handicap * 4 + handicap / 100).to_i
      solidh = h4 / 4
      remh = h4 % 4
      homevalue == 1 ? handicapvalue(homescore, awayscore, solidh, remh) : handicapvalue(awayscore, homescore, solidh, remh)
    end

  private

    def handicapvalue(homescore, awayscore, solidh, remh)
      case remh
      when 0
        homescore + solidh <=> awayscore
      when 1
        0.5 * (homescore + solidh <=> awayscore) + 0.5 * (homescore + solidh + 0.5 <=> awayscore)
      when 2
        homescore + solidh + 0.5 <=> awayscore
      when 3
        0.5 * (homescore + solidh + 0.5 <=> awayscore) + 0.5 * (homescore + solidh + 1 <=> awayscore)
      end
    end
  end
end

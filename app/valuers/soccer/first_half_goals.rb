# frozen_string_literal: true

#
# $Id$
#
require "soccer/over_under_goals"

module Soccer
  class FirstHalfGoals < HalfTimeValuer
    def value(homevalue, _awayvalue, homescore, awayscore)
      homevalue > 0 ? homescore + awayscore <=> homevalue : -homevalue <=> homescore + awayscore
    end

    def expected_value(marketvalue, pricelist)
      Soccer::OverUnderGoals.new.expected_value marketvalue, pricelist
    end
  end
end

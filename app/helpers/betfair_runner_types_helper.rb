# frozen_string_literal: true

#
# $Id$
#
module BetfairRunnerTypesHelper
  def full_runner_type_name(betfair_runner_type)
    h(betfair_runner_type.betfair_market_type.name + " - " + betfair_runner_type.name)
  end
end

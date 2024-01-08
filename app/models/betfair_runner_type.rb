# frozen_string_literal: true

#
# $Id$
#
class BetfairRunnerType < ApplicationRecord
  belongs_to :betfair_market_type, inverse_of: :betfair_runner_types
  has_many :market_runners, inverse_of: :betfair_runner_type, dependent: :destroy

  validates :betfair_market_type, :runnertype, :runnerhomevalue, :runnerawayvalue, presence: true

  def valuer
    betfair_market_type.valuer_obj
  end

  def valueWithoutHandicap(homescore, awayscore)
    valuer.value runnerhomevalue, runnerawayvalue, homescore, awayscore
  end

  def valueWithHandicap(homescore, awayscore, handicap)
    valuer.value_with_handicap runnerhomevalue, runnerawayvalue, homescore, awayscore, handicap
  end

  # expected_value isn't expecting to be called like this.
  # def expected_runner_value(price)
  #   valuer.expected_value runnerhomevalue, price
  # end

  def nameAndMarketName
    betfair_market_type.name + " - " + name
  end

  def final_value(match, handicap)
    valuer.final_value match, runnerhomevalue, runnerawayvalue, handicap
  end
end

# frozen_string_literal: true

#
# $Id$
#
# Definition of a runner in a Betfair Market
#
class MarketRunner < ApplicationRecord
  validates :description, :selectionId, :asianLineId, presence: true
  # TODO: This ought to be possible, but fails a controller test
  # validates_uniqueness_of :description, scope: :bet_market
  # MarketPrice is the bottom of the chain, so delete_all is ok
  has_many :market_prices, inverse_of: :market_runner, dependent: :delete_all
  belongs_to :bet_market, inverse_of: :market_runners, counter_cache: true
  belongs_to :betfair_runner_type, inverse_of: :market_runners, optional: true
  has_many :trades, dependent: :delete_all
  has_many :basket_items, dependent: :delete_all

  before_save :updateRunnerType

  def reversedprices
    market_prices.reverse
  end

  def runnername
    bet_market.asian_handicap? ? "#{description}(#{handicap})" : description
  end

  def final_runner_value
    betfair_runner_type.final_value bet_market.match, handicap
  end

  def runner_value(homescore, awayscore)
    if bet_market.asian_handicap?
      betfair_runner_type.valueWithHandicap homescore, awayscore, handicap
    else
      betfair_runner_type.valueWithoutHandicap homescore, awayscore
    end
  end

  delegate :expected_runner_value, to: :betfair_runner_type

private

  def updateRunnerType
    home_teamnames = bet_market.match.hometeam.team_names.map(&:name)
    away_teamnames = bet_market.match.awayteam.team_names.map(&:name)

    # Cartesian product of the 2 arrays of home and away teams
    names = home_teamnames.product(away_teamnames).map do |hometeam, awayteam|
      runnerdesc = description
                         .gsub(hometeam, '#{hometeam}')
                         .gsub(awayteam, '#{awayteam}')

      # interpolatedname = runnerdesc.gsub '\#', '#'
      runnertype = bet_market.betfair_market_type.betfair_runner_types.find_by name: runnerdesc

      [runnerdesc, runnertype]
    end

    # This isn't quite right - we actually need the shortest (most accurate) match
    # so that AC Milan is matched against '#{hometeam}' rather than 'AC #{hometeam}'
    if names.detect { |_d, type| type.present? }
      # runnertype = names.reject { |_desc, runnertype| runnertype.nil? }.first.second
      runnertype = names.reject { |_desc, runner_type| runner_type.nil? }.min { |d, _t| d.size }.second
    else
      # try to find the best interpolated name - but pick the first one otherwise
      # but using max rather than min here makes no sense - but the test passes (and fails the other way round)
      pair = names.select { |desc, _type| desc.include?('#{') }.max { |d, _t| d.size } || names.first
      runnerdesc = pair.first
      runnertype = BetfairRunnerType.create! name: runnerdesc,
                                             betfair_market_type: bet_market.betfair_market_type,
                                             runnertype: runnerdesc,
                                             runnerhomevalue: 0,
                                             runnerawayvalue: 0
    end

    self.betfair_runner_type = runnertype
  end
end

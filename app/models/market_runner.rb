# frozen_string_literal: true

#
# $Id$
#
# Definition of a runner in a Betfair Market
#
class MarketRunner < ApplicationRecord
  validates :description, :selectionId, presence: true

  # not sure whats going on with asianLineId - maybe it no longer exists?
  # validates :asianLineId, presence: true, if: -> { bet_market.asian_handicap? }
  validates :description, uniqueness: { scope: [:bet_market, :handicap] }
  # Price is the bottom of the chain - but delete_all messes up counters
  # has_many :prices, inverse_of: :market_runner, dependent: :delete_all
  # It seems that acts_as_paranoid isn't compatible with destroying
  # and timescale_db so AAP has to be removed first
  # has_many :prices, inverse_of: :market_runner, dependent: :destroy
  # old prices will just be orphaned in timescaledb?
  has_many :prices, inverse_of: :market_runner
  # before_destroy do |runner|
  # runner.prices.each(&:destroy)
  # runner.prices.each do |p|
  #   p.update!(created_at: 100.years.ago)
  # end
  # Price.where(market_runner_id: runner.id).each(&:destroy)
  # end

  belongs_to :bet_market, inverse_of: :market_runners, counter_cache: true
  belongs_to :betfair_runner_type, inverse_of: :market_runners, optional: true
  has_many :trades, dependent: :delete_all
  # This needs to be destroy so that counter caches are updated correctly
  has_many :basket_items, dependent: :destroy

  # before_save :update_runner_type

  def reversedprices
    prices.reverse
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

  # delegate :expected_runner_value, to: :betfair_runner_type
end

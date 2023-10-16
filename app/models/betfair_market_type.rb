# frozen_string_literal: true

#
# $Id$
#
class BetfairMarketType < ApplicationRecord
  belongs_to :sport, inverse_of: :betfair_market_types
  has_many :bet_markets, inverse_of: :betfair_market_type, dependent: :destroy
  has_many :betfair_runner_types, inverse_of: :betfair_market_type, dependent: :destroy

  validates :name, :valuer, presence: true

  HALF_TIME_MARKETS = %w[FirstHalfGoals HalfTime HalfTimeScore].freeze
  CORRECT_SCORE = ["Correct Score", "Correct Score 2"].freeze

  scope :half_time, -> { where(valuer: HALF_TIME_MARKETS) }
  scope :full_time, -> { where.not(valuer: HALF_TIME_MARKETS) }

  scope :correct_score, -> { where(name: CORRECT_SCORE) }

  def half_time?
    valuer.in? HALF_TIME_MARKETS
  end

  def valuer_obj
    # require "#{sport.name}/#{valuer.underscore}"
    # Module.const_get('Valuers').const_get(sport.name).const_get(valuer).new
    @valuer_obj ||= Module.const_get("#{sport.name}::#{valuer}").new
  end

  # prices is an array of homevalue, awayvalue, handicap, backprice & layprice
  # might make more sense for the prices to be treated individually?
  # param1 is a market parameter e.g. OverUnderGoals(1.5)
  def expected_value(prices)
    logger.debug "Expected value: [#{name}] param1:[#{param1}] prices:[#{prices.inspect}]"
    valuer_obj.expected_value(param1, prices)
  end

  class << self
    def ransackable_attributes(_auth_object = nil)
      %w[active created_at id name param1 sport_id updated_at valuer]
    end
  end
end

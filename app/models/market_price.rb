#
# $Id$
#
require "back_price_set"
require "lay_price_set"

class MarketPrice < ApplicationRecord
  belongs_to :market_runner, inverse_of: :market_prices, counter_cache: true
  belongs_to :market_price_time, inverse_of: :market_prices, counter_cache: true

  ACTIVE = "ACTIVE".freeze

  scope :active, -> { where(status: ACTIVE) }

  validates :status, inclusion: { in: %w(ACTIVE WINNER LOSER PLACED REMOVED_VACANT REMOVED HIDDEN), allow_nil: false }

  validate :at_least_one_price, unless: -> { inactive? }

  validates :market_runner, uniqueness: { scope: :market_price_time }

  delegate :bet_market, to: :market_runner

  counter_culture %i[market_runner bet_market match]
  counter_culture %i[market_runner bet_market]

  def active?
    status == ACTIVE
  end

  def inactive?
    !active?
  end

  def back_price_set
    BackPriceSet.new [back1price, back1amount],
                     [back2price, back2amount],
                     [back3price, back3amount]
  end

  def lay_price_set
    LayPriceSet.new [lay1price, lay1amount],
                    [lay2price, lay2amount],
                    [lay3price, lay3amount]
  end

private

  def at_least_one_price
    errors.add(:back1price, "needs at least one price") unless back1price || lay1price
  end
end

#
# $Id$
#
# This now represents a 'capture' event which is pretty free-floating
class MarketPriceTime < ApplicationRecord
  # need to destroy as there is a counter cache involved...
  # has_many :market_prices, inverse_of: :market_price_time, dependent: :destroy
  has_many :prices, inverse_of: :market_price_time, dependent: :destroy

  # default_scope -> { order(:time) }
  scope :in_order, -> { order(:time) }
  scope :reversed, -> { reorder(nil).order(time: :desc) }
  scope :later_than, ->(time) { where("time > ?", time) }
  # scope :earlier_than, ->(time) { where("time <= ?", time) }

  validates :time, presence: true
end

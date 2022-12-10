# frozen_string_literal: true

#
# $Id$
#
# This now represents a 'capture' event which is pretty free-floating
class MarketPriceTime < ApplicationRecord
  # need to destroy as there is a counter cache involved...
  has_many :market_prices, inverse_of: :market_price_time, dependent: :destroy

  default_scope -> { order(:time) }

  scope :reversed, -> { reorder(nil).order(time: :desc) }

  validates :time, presence: true
end

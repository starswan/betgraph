# frozen_string_literal: true

#
# $Id$
#
class BasketItem < ApplicationRecord
  validates :market_runner, :weighting, presence: true

  belongs_to :basket, inverse_of: :basket_items, counter_cache: true
  belongs_to :market_runner, inverse_of: :basket_items
end

# frozen_string_literal: true

#
# $Id$
#
class Trade < ApplicationRecord
  #  attr_accessible :size, :price, :side

  belongs_to :market_runner, inverse_of: :trades
  validates :size, :price, :side, presence: true
end

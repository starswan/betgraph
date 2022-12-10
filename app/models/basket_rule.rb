# frozen_string_literal: true

#
# $Id$
#
class BasketRule < ApplicationRecord
  belongs_to :sport
  has_many :basket_rule_items, dependent: :destroy
  has_many :baskets, inverse_of: :basket_rule, dependent: :destroy

  validates :name, presence: true
end

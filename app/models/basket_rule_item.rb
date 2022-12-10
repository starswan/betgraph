# frozen_string_literal: true

#
# $Id$
#
class BasketRuleItem < ApplicationRecord
  validates :weighting, presence: true, numericality: true

  belongs_to :basket_rule
  belongs_to :betfair_runner_type

  after_create do |rule_item|
    rule_item.basket_rule.count += 1
    rule_item.basket_rule.save!
  end

  before_destroy do |rule_item|
    rule_item.basket_rule.count -= 1
    rule_item.basket_rule.save!
  end
end

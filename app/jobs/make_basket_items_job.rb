# frozen_string_literal: true

#
# $Id$
#
class MakeBasketItemsJob < ApplicationJob
  queue_priority PRIORITY_MAKE_BASKET_ITEMS

  def perform(market_runner)
    BasketRuleItem.includes(:basket_rule).where(betfair_runner_type_id: market_runner.betfair_runner_type_id).each do |basket_rule_item|
      basket_rule = basket_rule_item.basket_rule
      basket = market_runner.bet_market.match.baskets.find_or_create_by! basket_rule_id: basket_rule.id do |b|
        b.missing_items_count = basket_rule.count
      end
      logger.debug "Creating basket items #{basket_rule.basket_rule_items.count} #{basket.basket_items.count} [#{market_runner.bet_market.name}] [#{basket_rule.name}] [#{market_runner.bet_market.match.name}]"
      basket.basket_items.create! weighting: basket_rule_item.weighting,
                                  market_runner_id: market_runner.id unless basket.basket_items.detect { |item| item.market_runner == market_runner }
      logger.debug "Create basket items #{basket_rule.basket_rule_items.count} #{basket.basket_items.count} [#{market_runner.bet_market.name}] [#{basket_rule.name}] [#{market_runner.bet_market.match.name}]"
    end
  end
end

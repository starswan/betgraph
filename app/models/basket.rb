# frozen_string_literal: true

#
# $Id$
#
require "runner_set"

class Basket < ApplicationRecord
  belongs_to :match, inverse_of: :baskets
  has_many :basket_items, dependent: :destroy
  belongs_to :basket_rule, inverse_of: :baskets

  validates :missing_items_count, presence: true

  scope :complete, -> { where("missing_items_count = basket_items_count") }

  def complete?
    missing_items_count == basket_items_count
  end

  def event_basket_prices
    market_runners = basket_items.map(&:market_runner)
    # bet_markets = match.bet_markets.select { |bm| market_runners.detect { |mr| mr.bet_market_id == bm.id } }

    Enumerator.new do |yielder|
      prices = MarketPrice.includes(:market_price_time, { market_runner: :bet_market }).joins(:market_price_time)
        .where(market_runner_id: market_runners.map(&:id))
                          .merge(MarketPriceTime.in_order)
      prices.group_by { |p| p.market_price_time.time }.each do |time, price_group|
        back_runners = RunnerSet.new
        lay_runners = RunnerSet.new
        price_group.each do |market_price|
          # Try to lay other runner rather than backing this and vice-versa
          # this doesn't quite work as we have excluded the prices for other runner from the price_group
          # market = market_price.market_runner.bet_market
          # if market.market_runners_count == 2
          #   layrunner = market.market_runners.detect { |r| r != market_price.market_runner }
          #   layprice = market_prices_hash[market.id].detect { |mp| mp.market_runner == layrunner }
          #   if layprice
          #     layprices = layprice.lay_price_set
          #
          #     pricedata = layprices if layprices.overRound < pricedata.overRound
          #   end
          # end

          back_runners.addPriceSet(market_price.market_runner, market_price.back_price_set)
          lay_runners.addPriceSet(market_price.market_runner, market_price.lay_price_set)
        end
        runners, bet_type = back_runners.over_round < lay_runners.over_round ? [back_runners, "B"] : [lay_runners, "L"]
        if market_runners.count == runners.count
          yielder << { time: time,
                       betsize: runners.min_amount.to_f,
                       betType: bet_type,
                       market_prices: price_group.map { |p| [p.back1price.to_f, p.back1amount.to_f] },
                       price: runners.over_round.to_f }
        end
      end
    end
  end
end

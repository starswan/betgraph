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

  class EventBasketPriceIterator
    include Enumerable

    def initialize(bet_markets, market_runners)
      @bet_markets = bet_markets.select { |bm| market_runners.detect { |mr| mr.bet_market_id == bm.id } }
      @market_runners = market_runners
    end

    def each
      times = @bet_markets.map { |bm| bm.market_prices.map(&:market_price_time) }.flatten.sort_by(&:time).uniq

      market_prices_hash = {}
      times.each do |time|
        # market_prices_hash[time.bet_market_id] = time.market_prices
        market_prices_hash.merge!(time.market_prices.group_by { |mp| mp.market_runner.bet_market_id })
        # time.market_prices.each do |mp|
        #   market_prices_hash[mp.market_runner.bet_market_id] << mp
        # end
        backRunnerSet = RunnerSet.new
        layRunnerSet = RunnerSet.new
        market_prices_hash.values.each do |p|
          p.select { |mp| @market_runners.include?(mp.market_runner) }.each do |market_price|
            market_runner = market_price.market_runner
            market = @bet_markets.find { |bm| bm.id == market_runner.bet_market_id }

            pricedata = market_price.back_price_set
            # Try to lay other runner rather than backing this and vice-versa
            if market.market_runners_count == 2
              layrunner = market.market_runners.detect { |r| r != market_runner }
              layprice = market_prices_hash[market.id].detect { |mp| mp.market_runner == layrunner }
              if layprice
                layprices = layprice.lay_price_set

                pricedata = layprices if layprices.overRound < pricedata.overRound
              end
            end
            backRunnerSet.addPriceSet(market_runner, pricedata)
            laydata = market_price.lay_price_set

            layRunnerSet.addPriceSet(market_runner, laydata)
          end
        end
        runnerSet, betType = backRunnerSet.overRound < layRunnerSet.overRound ? [backRunnerSet, "B"] : [layRunnerSet, "L"]

        if @market_runners.count == runnerSet.count
          yield OpenStruct.new time: time.time,
                               betsize: runnerSet.minAmount.to_f,
                               betType: betType,
                               price: runnerSet.overRound.to_f
          # prices: runnerSet.effectivePrices
        end
      end
    end
  end

  def event_basket_prices
    EventBasketPriceIterator.new(match.bet_markets, basket_items.map(&:market_runner))
  end
end

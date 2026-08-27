# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe EventBasketPricesController, type: :controller do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sm) { create(:soccer_match, division: division) }

  before do
    mpt = create(:market_price_time)
    bm1 = create(:bet_market, match: sm)
    mr1 = create(:market_runner, bet_market: bm1)
    create_list(:price, 1, market_runner: mr1, back_price: 1.9, back_amount: 25, depth: 1, market_price_time: mpt)
    create(:market_runner, bet_market: bm1,
                           prices: build_list(:price, 1, lay_price: 1.98, lay_amount: 126.51, depth: 1, market_price_time: mpt))
    create(:bet_market, :overunder,
           match: sm,
           market_runners: [
             build(:market_runner,
                   prices: build_list(:price, 1, back_price: 1.9, back_amount: 25, depth: 1, market_price_time: mpt)),
             build(:market_runner,
                   prices: build_list(:price, 1, lay_price: 1.99, lay_amount: 111.0, depth: 1, market_price_time: mpt)),
           ])
  end

  describe "index" do
    let(:basket) do
      create(:basket, match: sm, basket_items: [
        build(:basket_item, market_runner: sm.bet_markets.first.market_runners.last),
        build(:basket_item, market_runner: sm.bet_markets.last.market_runners.last),
      ])
    end

    let(:prices) do
      assigns(:event_basket_prices).map { |k| k.except(:time).merge(market_prices: k.fetch(:market_prices).map { |p| p.except(:runner) }) }
    end

    it "gets index" do
      get :index, params: { basket_id: basket.id }
      expect(response).to be_successful
      expect(prices.map { |p| p.except(:market_prices, :price) })
        .to eq([{
          betsize: 0.98,
          betType: "L",
          # flakes between 0.9926 and 0.9925
          # price: 0.9926,
        }])
      expect(prices.map { |p| p.fetch(:market_prices) }.first)
        .to match_array(
          [
            { amount: 109.89, price: 2.02, weight: 109.89 },
            { amount: 123.9798, price: 2.01, weight: 110.45 },
          ],
        )
    end
  end
end

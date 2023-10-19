#
# $Id$
#
require "rails_helper"

RSpec.describe Basket do
  let(:sport) { create(:sport, basket_rules: [build(:basket_rule, name: "Rule 1")]) }
  let(:hometeam) { create(:team) }
  let(:awayteam) { create(:team) }
  let(:menu_path) { create(:menu_path, sport: sport) }
  let(:soccermatch) do
    create(:soccer_match,
           live_priced: true, division: division,
           name: "#{hometeam.name} v #{awayteam.name}")
  end
  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }
  let(:runner_type) { create(:betfair_runner_type, betfair_market_type: market_type) }
  let(:runner_type2) { create(:betfair_runner_type, betfair_market_type: market_type) }

  before do
    create(:season, calendar: calendar)
    create(:basket_rule_item, basket_rule: sport.basket_rules.first, betfair_runner_type: runner_type)
    create(:basket_rule_item, basket_rule: sport.basket_rules.first, betfair_runner_type: runner_type2)
  end

  describe "creating baskets based on rules" do
    it "creating an match creates baskets matching basket rules" do
      expect {
        division.matches.create! name: "Fred v Jim", type: "SoccerMatch",
                                 kickofftime: Time.zone.now,
                                 venue: hometeam
      }.to change(described_class, :count).by(1)
    end
  end

  describe "#complete" do
    let(:market) do
      create(:bet_market, match: soccermatch,
                          market_runners: [build(:market_runner, betfair_runner_type: runner_type),
                                           build(:market_runner, betfair_runner_type: runner_type2)])
    end

    it "has complete baskets" do
      expect {
        create(:basket, match: soccermatch, missing_items_count: 3,
                        basket_items: [build(:basket_item, market_runner: market.market_runners.first)])
        create(:basket, match: soccermatch, missing_items_count: 2,
                        basket_items: [build(:basket_item, market_runner: market.market_runners.first),
                                       build(:basket_item, market_runner: market.market_runners.second)])
        create(:basket, match: soccermatch, missing_items_count: 1,
                        basket_items: [build(:basket_item, market_runner: market.market_runners.second)])
      }.to change { described_class.complete.count }.by(2)
    end
  end

  describe "#event_basket_prices" do
    let(:now) { create(:sport).created_at }
    let(:mpt2) { now - 2.minutes }
    let(:mpt3) { now - 1.minute }
    let(:basket) { described_class.last }
    let(:expected1) { { time: mpt2.to_s, betsize: 1.0, betType: "B", price: 1.0 } }
    let(:expected2) { { time: mpt3.to_s, betsize: 1.0, betType: "B", price: 1.0 } }

    before do
      mt2 = create :market_price_time,
                   time: mpt2
      # market_prices: [
      #   build(:market_price, market_runner: m1.market_runners.first, back1price: 2),
      #   build(:market_price, market_runner: m1.market_runners.second, back1price: 2),
      #   build(:market_price, market_runner: m2.market_runners.first, back1price: 2),
      #   build(:market_price, market_runner: m2.market_runners.second, back1price: 2),
      # ])
      mt3 = create :market_price_time,
                   time: mpt3
      # market_prices: [
      #   build(:market_price, market_runner: m1.market_runners.first, back1price: 2),
      #   build(:market_price, market_runner: m1.market_runners.second, back1price: 2),
      #   build(:market_price, market_runner: m2.market_runners.first, back1price: 2),
      #   build(:market_price, market_runner: m2.market_runners.second, back1price: 2),
      # ])
      m1 = create(:bet_market,
                  match: soccermatch,
                  name: "Market1",
                  market_runners: [
                    build(:market_runner, prices: [
                      build(:price, back_price: 2, market_price_time: mt2, created_at: mpt2),
                      build(:price, back_price: 2, market_price_time: mt3, created_at: mpt3),
                    ]),
                    build(:market_runner, prices: [
                      build(:price, back_price: 2, market_price_time: mt2, created_at: mpt2),
                      build(:price, back_price: 2, market_price_time: mt3, created_at: mpt3),
                    ]),
                  ])

      m2 = create(:bet_market,
                  match: soccermatch,
                  name: "Market2",
                  market_runners: [
                    build(:market_runner, prices: [
                      build(:price, back_price: 2, market_price_time: mt2, created_at: mpt2),
                      build(:price, back_price: 2, market_price_time: mt3, created_at: mpt3),
                    ]),
                    build(:market_runner, prices: [
                      build(:price, back_price: 2, market_price_time: mt2, created_at: mpt2),
                      build(:price, back_price: 2, market_price_time: mt3, created_at: mpt3),
                    ]),
                  ])
      create(:basket,
             match: soccermatch,
             basket_items: [
               build(:basket_item, market_runner: m1.market_runners.first),
               build(:basket_item, market_runner: m2.market_runners.second, weighting: -1),
             ])
    end

    it "has the correct values" do
      expect(basket.event_basket_prices.map { |g| g.except(:market_prices).merge(time: g.fetch(:time).to_s) })
        .to match_array([expected1, expected2])
    end
  end
  #   test "creating a market runner creates basket items matching basket rule items" do
  #      assert_difference('BasketItem.count', 2) do
  #         market = bet_markets(:one)
  #         market.market_runners.create! :description => 'Desc',
  #                                       :selectionId => 4,
  #                                       :asianLineId => 0,
  #                                       :betfair_runner_type => betfair_runner_types(:hometeam)
  #      end
  #   end
end

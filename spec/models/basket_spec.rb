# frozen_string_literal: true

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

  before do
    create(:season, calendar: calendar)
  end

  describe "creating baskets based on rules" do
    it "creating an match creates baskets matching basket rules" do
      expect {
        division.matches.create! name: "Fred v Jim", type: "SoccerMatch",
                                 kickofftime: Time.now,
                                 venue: hometeam
      }.to change(described_class, :count).by(1)
    end
  end

  describe "#complete" do
    let(:market) { create(:bet_market, match: soccermatch, market_runners: [build(:market_runner), build(:market_runner)]) }

    it "has complete baskets" do
      expect {
        create(:basket, match: soccermatch, missing_items_count: 2,
                        basket_items: [build(:basket_item, market_runner: market.market_runners.first)])
        create(:basket, match: soccermatch, missing_items_count: 1,
                        basket_items: [build(:basket_item, market_runner: market.market_runners.second)])
      }.to change { described_class.complete.count }.by(2)
    end
  end

  describe "#event_basket_prices" do
    let!(:market1) do
      create(:bet_market,
             match: soccermatch,
             market_runners: [
               build(:market_runner),
               build(:market_runner),
             ])
    end
    let!(:market2) do
      create(:bet_market,
             match: soccermatch,
             market_runners: [
               build(:market_runner),
               build(:market_runner),
             ])
    end
    let!(:price_time1) do
      create(:market_price_time,
             market_prices: [
               build(:market_price, market_runner: market1.market_runners.first),
               build(:market_price, market_runner: market1.market_runners.second),
             ])
    end
    let!(:price_time2) do
      create(:market_price_time,
             market_prices: [
               build(:market_price, market_runner: market2.market_runners.first),
               build(:market_price, market_runner: market2.market_runners.second),
             ])
    end
    let!(:price_time3) do
      create(:market_price_time,
             market_prices: [
               build(:market_price, market_runner: market1.market_runners.first),
               build(:market_price, market_runner: market1.market_runners.second),
             ])
    end
    let!(:basket) do
      create(:basket,
             match: soccermatch,
             basket_items: [
               build(:basket_item, market_runner: market1.market_runners.first),
               build(:basket_item, market_runner: market2.market_runners.second, weighting: -1),
             ])
    end
    let(:expected1) { OpenStruct.new(time: price_time2.time, betsize: 2.0, price: 4.0 / 3, betType: "B") }
    let(:expected2) { OpenStruct.new(time: price_time3.time, betsize: 2.0, price: 4.0 / 3, betType: "B") }

    it "has the correct values" do
      expect(basket.event_basket_prices.to_a).to eq([expected1, expected2])
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

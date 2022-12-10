# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe MarketPrice do
  before do
    create(:season, calendar: calendar)
  end

  let(:sport) { create(:sport, basket_rules: [build(:basket_rule, name: "Rule 1")]) }
  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }
  let(:hometeam) { create(:team) }
  let(:awayteam) { create(:team) }
  let(:menu_path) { create(:menu_path, sport: sport) }
  let(:soccermatch) do
    create(:soccer_match, live_priced: true, division: division,
                          name: "#{hometeam.name} v #{awayteam.name}")
  end

  context "active" do
    let!(:market) do
      create(:bet_market, match: soccermatch, market_runners: [
        build(:market_runner),
        build(:market_runner),
      ])
    end

    it "factory makes active items" do
      expect {
        create(:market_price_time, market_prices: [
          build(:market_price, market_runner: market.market_runners.first),
          build(:market_price, market_runner: market.market_runners.second),
        ])
      }.to change { described_class.active.count }.by(2)
    end
  end

  context "fixtures" do
    before do
      market =
        create(:bet_market, match: soccermatch, market_runners: [
          build(:market_runner),
          build(:market_runner),
        ])
      create(:market_price_time,
             market_prices: [build(:market_price, market_runner: market.market_runners.first)])
    end

    let(:price) { described_class.last }
    let(:market) { BetMarket.last }

    it "market prices exist" do
      expect(price.back1price.to_f).to eq(1.5)
    end

    it "can write a market price of 1000." do
      expect(price.market_price_time.market_prices.build(back1price: 1000.0, market_runner: market.market_runners.first)).to be_valid
    end
  end

  context "validation" do
    let(:runner) { build(:market_runner) }
    let(:mpt) { build(:market_price_time) }

    it "needs either a back1price or a lay1price" do
      expect(build(:market_price, market_runner: runner, market_price_time: mpt, back1price: nil, lay1price: nil)).not_to be_valid
      expect(build(:market_price,  market_runner: runner, market_price_time: mpt, back1price: 0.8, lay1price: nil)).to be_valid
      expect(build(:market_price,  market_runner: runner, market_price_time: mpt, back1price: nil, lay1price: 0.8)).to be_valid
    end
  end
end

#
# $Id$
#
require "rails_helper"

RSpec.describe MarketPrice do
  before do
    create(:season, calendar: calendar)
  end

  let(:sport) { create(:sport) }
  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }
  let(:hometeam) { create(:team) }
  let(:awayteam) { create(:team) }
  let(:soccermatch) do
    create(:soccer_match, live_priced: true, division: division,
                          name: "#{hometeam.name} v #{awayteam.name}")
  end

  describe "#active" do
    let(:market) do
      create(:bet_market, match: soccermatch, market_runners: [
        build(:market_runner),
        build(:market_runner),
      ])
    end
    let(:market2) do
      create(:bet_market, :overunder, match: soccermatch, market_runners: [
        build(:market_runner),
        build(:market_runner),
      ])
    end
    let(:runner) { market.market_runners.first }
    let(:runner2) { market.market_runners.last }
    let(:runner3) { market2.market_runners.first }
    let(:runner4) { market2.market_runners.last }
    let(:count_models) { [soccermatch, market, market2, runner, runner2, runner3, runner4] }

    it "has the correct counter caches" do
      expect(count_models.map(&:market_prices_count)).to eq([0, 0, 0, 0, 0, 0, 0])
      create(:market_price_time, market_prices: build_list(:market_price, 1, market_runner: runner))
      expect(count_models.map(&:reload).map(&:market_prices_count)).to eq([1, 1, 0, 1, 0, 0, 0])
      create(:market_price_time, market_prices: build_list(:market_price, 1, market_runner: runner2))
      expect(count_models.map(&:reload).map(&:market_prices_count)).to eq([2, 2, 0, 1, 1, 0, 0])
      create(:market_price_time, market_prices: build_list(:market_price, 1, market_runner: runner3))
      create(:market_price_time, market_prices: build_list(:market_price, 1, market_runner: runner4))
      expect(count_models.map(&:reload).map(&:market_prices_count)).to eq([4, 2, 2, 1, 1, 1, 1])
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

    it "market prices exists" do
      expect(price.back1price.to_f).to eq(1.5)
    end

    it "can write a market price of 1000." do
      expect(price.market_price_time.market_prices.build(back1price: 1000.0,
                                                         market_runner: market.market_runners.last)).to be_valid
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

  describe "#bet_market.market_price_count" do
    let(:bet_market) do
      create(:bet_market, live: true, betfair_market_type: market_type, match: soccermatch, market_runners: [
        build(:market_runner, trades: [build(:trade, side: "L")]),
        build(:market_runner, trades: [build(:trade)]),
        build(:market_runner),
      ])
    end

    before do
      create(:market_price_time,
             time: Time.zone.now - 1.minute,
             market_prices: [
               build(:market_price,
                     back3price: 2.42, back3amount: 296.69,
                     back2price: 2.44, back2amount: 60.38,
                     back1price: 2.46, back1amount: 196.71,
                     lay1price: 2.54, lay1amount: 135.62,
                     lay2price: 2.56, lay2amount: 48.18,
                     lay3price: 2.58, lay3amount: 148.67,
                     market_runner: bet_market.market_runners.first),
               build(:market_price,
                     back3price: 3.15, back3amount: 48.48,
                     back2price: 3.2, back2amount: 88.26,
                     back1price: 3.25, back1amount: 101.30,
                     lay1price: 3.35, lay1amount: 252.63,
                     lay2price: 3.4, lay2amount: 310.99,
                     lay3price: 3.45, lay3amount: 369.34,
                     market_runner: bet_market.market_runners.second),
               build(:market_price,
                     back3price: 3.25, back3amount: 253.13,
                     back2price: 3.3, back2amount: 61.11,
                     back1price: 3.35, back1amount: 228.44,
                     lay1price: 3.45, lay1amount: 48.90,
                     lay2price: 3.5, lay2amount: 125.10,
                     lay3price: 3.55, lay3amount: 52.40,
                     market_runner: bet_market.market_runners.third),
             ])

      create(:market_price_time,
             time: Time.zone.now,
             market_prices: [
               build(:market_price,
                     market_runner: bet_market.market_runners.first),
               build(:market_price, :good_lay_price,
                     market_runner: bet_market.market_runners.second),
               build(:market_price, :good_lay_price,
                     market_runner: bet_market.market_runners.third),
             ])
    end

    it "counts market prices using counters" do
      expect(bet_market.reload.market_prices_count).to eq(6)
    end
  end
end

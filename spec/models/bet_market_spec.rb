#
# $Id$
#
require "rails_helper"

RSpec.describe BetMarket do
  let(:sport) { create(:soccer) }
  let(:market_type) { create(:betfair_market_type, sport: sport) }
  let(:runner_type) { create(:betfair_runner_type, betfair_market_type: market_type) }
  let(:runner_type2) { create(:betfair_runner_type, betfair_market_type: market_type) }
  let(:runner_type3) { create(:betfair_runner_type, betfair_market_type: market_type) }
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }
  let(:hometeam) { create(:team) }
  let(:awayteam) { create(:team) }
  let(:menu_path) { create(:menu_path, sport: sport) }
  let(:soccermatch) do
    create(:soccer_match, live_priced: true, division: division,
                          name: "#{hometeam.name} v #{awayteam.name}")
  end
  let(:bet_market) do
    create(:bet_market, live: true, betfair_market_type: market_type, match: soccermatch, market_runners: [
      build(:market_runner, betfair_runner_type: runner_type, trades: [build(:trade, side: "L")]),
      build(:market_runner, betfair_runner_type: runner_type2, trades: [build(:trade)]),
      build(:market_runner, betfair_runner_type: runner_type3),
    ])
  end

  before do
    create(:season, calendar: calendar)
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

  describe "#winners" do
    before do
      soccermatch.reload
    end

    it "produces winners based on short lay prices first" do
      expect(bet_market.winners).to eq([bet_market.market_runners.second])
    end
  end

  describe "#closed" do
    let!(:closed_market) { create(:bet_market, :closed, name: "Fred", match: soccermatch) }

    it "shows closed markets" do
      expect(described_class.closed).to eq([closed_market])
    end
  end

  it "different sports produce different market types" do
    expect {
      create(:bet_market, match: soccermatch, name: "Fred")
      create(:bet_market, match: soccermatch, name: "Jim")
    }.to change(BetfairMarketType, :count).by(2)
  end

  describe "#destroy" do
    it "destroys runners when market is destroyed" do
      expect {
        bet_market.destroy
      }.to change(MarketRunner, :count).by(-3)
    end

    it "destroys market prices when market destroyed" do
      expect {
        bet_market.really_destroy!
      }.to change(MarketPrice, :count).by(-6)
    end
  end

  describe "#active" do
    it "shows only active markets" do
      expect(described_class.active).to eq([bet_market])
    end
  end

  describe "#activelive" do
    let(:market_type) { create(:betfair_market_type, sport: sport, name: "Things", active: true) }
    let!(:livebm) do
      create(:bet_market, match: soccermatch, name: market_type.name,
                          time: Time.zone.now - 10.minutes, live: true)
    end

    it "has active things" do
      expect(described_class.activelive.map(&:name)).to eq(%w[Things])
    end
  end

  it "can create brand new market" do
    expect {
      expect {
        create(:bet_market, name: "Fred", match: soccermatch)
        soccermatch.reload
      }.to change(described_class, :count).by(1)
    }.to change(soccermatch, :bet_markets_count).by(1)
  end

  describe "#market_value" do
    it "allows a market to be valued based on time and score" do
      expect(bet_market.market_value(bet_market.time + 51.minutes, 2, 0)).to eq(0)
    end
  end

  describe "#trades" do
    it "has sides" do
      expect(bet_market.trades.map(&:side)).to match_array(%w[L B])
    end
  end

  it "prevents new match from being created if parent exists" do
    expect {
      create(:bet_market, name: "Fred", match: soccermatch)
    }.to change(Match, :count).by(0)
  end

  it "prevents duplicate markets on same match" do
    expect(soccermatch.bet_markets.create(name: soccermatch.bet_markets.last.name)).not_to be_valid
  end
end

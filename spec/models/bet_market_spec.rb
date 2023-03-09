# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe BetMarket do
  let(:sport) { create(:soccer) }
  let(:market_type) { create(:betfair_market_type, sport: sport) }
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }
  let(:hometeam) { create(:team) }
  let(:awayteam) { create(:team) }
  let(:menu_path) { create(:menu_path, sport: sport) }
  let(:one_minute_ago) do
    create :market_price_time,
           time: Time.zone.now - 1.minute
    # market_prices: [
    #   build(:market_price,
    #         back3price: 2.42, back3amount: 296.69,
    #         back2price: 2.44, back2amount: 60.38,
    #         back1price: 2.46, back1amount: 196.71,
    #         lay1price: 2.54, lay1amount: 135.62,
    #         lay2price: 2.56, lay2amount: 48.18,
    #         lay3price: 2.58, lay3amount: 148.67,
    #         market_runner: bet_market.market_runners.first),
    #   build(:market_price,
    #         back3price: 3.15, back3amount: 48.48,
    #         back2price: 3.2, back2amount: 88.26,
    #         back1price: 3.25, back1amount: 101.30,
    #         lay1price: 3.35, lay1amount: 252.63,
    #         lay2price: 3.4, lay2amount: 310.99,
    #         lay3price: 3.45, lay3amount: 369.34,
    #         market_runner: bet_market.market_runners.second),
    #   build(:market_price,
    #         back3price: 3.25, back3amount: 253.13,
    #         back2price: 3.3, back2amount: 61.11,
    #         back1price: 3.35, back1amount: 228.44,
    #         lay1price: 3.45, lay1amount: 48.90,
    #         lay2price: 3.5, lay2amount: 125.10,
    #         lay3price: 3.55, lay3amount: 52.40,
    #         market_runner: bet_market.market_runners.third),
    # ])
  end
  let(:mpt_now) do
    create :market_price_time,
           time: Time.zone.now
    # market_prices: [
    #   build(:market_price,
    #         market_runner: bet_market.market_runners.first),
    #   build(:market_price, :good_lay_price,
    #         market_runner: bet_market.market_runners.second),
    #   build(:market_price, :good_lay_price,
    #         market_runner: bet_market.market_runners.third),
    # ])
  end
  let(:soccermatch) do
    create(:soccer_match, live_priced: true, division: division,
           name: "#{hometeam.name} v #{awayteam.name}",
           bet_markets: build_list(:bet_market, 1, live: true, betfair_market_type: market_type,
                                   market_runners: [
                                     build(:market_runner, prices: [
                                       build(:price, price: 2.42, amount: 296.69, side: "B", depth: 3, market_price_time: one_minute_ago, created_at: one_minute_ago.time),
        build(:price, price: 2.44, amount: 60.38, side: "B", depth: 2, market_price_time: one_minute_ago, created_at: one_minute_ago.time),
        build(:price, price: 2.46, amount: 196.71, side: "B", depth: 1, market_price_time: one_minute_ago, created_at: one_minute_ago.time),
        build(:price, price: 2.54, amount: 135.62, side: "L", depth: 1, market_price_time: one_minute_ago, created_at: one_minute_ago.time),
        build(:price, price: 2.56, amount: 48.18, side: "L", depth: 2, market_price_time: one_minute_ago, created_at: one_minute_ago.time),
        build(:price, price: 2.58, amount: 148.67, side: "L", depth: 3, market_price_time: one_minute_ago, created_at: one_minute_ago.time),
        build(:price, market_price_time: mpt_now, created_at: mpt_now.time),
      ], trades: [build(:trade, side: "L")]),
      build(:market_runner, prices: [
        build(:price, price: 3.15, amount: 48.48, side: "B", depth: 3, market_price_time: one_minute_ago, created_at: one_minute_ago.time),
        build(:price, price: 3.2, amount: 88.26, side: "B", depth: 2, market_price_time: one_minute_ago, created_at: one_minute_ago.time),
        build(:price, price: 3.25, amount: 101.30, side: "B", depth: 1, market_price_time: one_minute_ago, created_at: one_minute_ago.time),
        build(:price, price: 3.35, amount: 252.63, side: "L", depth: 1, market_price_time: one_minute_ago, created_at: one_minute_ago.time),
        build(:price, price: 3.4, amount: 310.99, side: "L", depth: 2, market_price_time: one_minute_ago, created_at: one_minute_ago.time),
        build(:price, price: 3.45, amount: 369.34, side: "L", depth: 3, market_price_time: one_minute_ago, created_at: one_minute_ago.time),
        build(:price, :good_lay_price, market_price_time: mpt_now, created_at: mpt_now.time),
      ], trades: [build(:trade)]),
      build(:market_runner, prices: [
        build(:price, price: 3.25, amount: 253.13, side: "B", depth: 3, market_price_time: one_minute_ago, created_at: one_minute_ago.time),
        build(:price, price: 3.3, amount: 61.11, side: "B", depth: 2, market_price_time: one_minute_ago, created_at: one_minute_ago.time),
        build(:price, price: 3.35, amount: 228.44, side: "B", depth: 1, market_price_time: one_minute_ago, created_at: one_minute_ago.time),
        build(:price, price: 3.45, amount: 48.90, side: "L", depth: 1, market_price_time: one_minute_ago, created_at: one_minute_ago.time),
        build(:price, price: 3.5, amount: 125.10, side: "L", depth: 2, market_price_time: one_minute_ago, created_at: one_minute_ago.time),
        build(:price, price: 3.5, amount: 52.40, side: "L", depth: 3, market_price_time: one_minute_ago, created_at: one_minute_ago.time),
        build(:price, :good_lay_price, market_price_time: mpt_now, created_at: mpt_now.time),
      ]),
    ]))
  end
  let(:bet_market) { soccermatch.bet_markets.first }

  before do
    create(:season, calendar: calendar)
  end

  it "market runners have price count" do
    expect(bet_market.market_runners.first.prices_count).to eq(7)
    expect(bet_market.market_runners.second.prices_count).to eq(7)
  end

  it "market has a price count" do
    expect(bet_market.reload.prices_count).to eq(21)
  end

  it "produces winners based on short lay prices first" do
    expect(soccermatch.prices.count).to eq(21)
    expect(bet_market.winners).to eq([bet_market.market_runners.second])
  end

  describe "#closed" do
    let!(:closed_market) { create(:bet_market, :closed, match: soccermatch) }

    it "shows closed markets" do
      expect(described_class.closed).to eq([closed_market])
    end
  end

  it "different sports produce different market types" do
    soccermatch
    expect {
      create(:bet_market, match: soccermatch, name: "Fred")
      create(:bet_market, match: soccermatch, name: "Jim")
    }.to change(BetfairMarketType, :count).by(2)
  end

  it "runners are destroyed when market destroyed" do
    bet_market
    expect {
      bet_market.destroy
    }.to change(MarketRunner, :count).by(-3)
  end

  it "market price times are destroyed when market destroyed" do
    bet_market
    expect {
      bet_market.destroy_fully!
    }.to change(Price, :count).by(-21)
  end

  it "active" do
    expect(described_class.active).to eq([bet_market])
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
        create(:bet_market, match: soccermatch)
        soccermatch.reload
      }.to change(described_class, :count).by(1)
    }.to change(soccermatch, :bet_markets_count).by(1)
  end

  it "market can be valued" do
    expect(bet_market.market_value(bet_market.time + 51.minutes, 2, 0)).to eq(0)
  end

  it "market can be open" do
    expect(bet_market.open?).to eq(true)
  end

  describe "#trades" do
    it "has sides" do
      expect(bet_market.trades.map(&:side)).to eq(%w[L B])
    end
  end

  it "new match not created if parent exists" do
    bet_market
    expect {
      create(:bet_market, match: soccermatch)
    }.to change(Match, :count).by(0)
  end
end

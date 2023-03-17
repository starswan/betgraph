# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe BetMarketsHelper, type: :helper do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }

  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:hometeam) { create(:team) }
  let(:awayteam) { create(:team) }
  let!(:soccermatch) do
    create(:soccer_match, division: division,
                          name: "#{hometeam.name} v #{awayteam.name}")
  end

  let!(:market1) do
    create(:bet_market,
           name: "Market One",
           match: soccermatch,
           market_runners: [
             build(:market_runner, description: "Runner"),
             build(:market_runner),
           ],
           time: soccermatch.kickofftime,
           markettype: market_type.name)
  end
  let(:r1) { market1.market_runners.first }
  let(:runner2) { market1.market_runners.last }

  let!(:mpt1) do
    create(:market_price_time,
           time: Time.zone.now,
           market_prices: [
             build(:market_price, market_runner: r1),
             build(:market_price, market_runner: runner2),
           ])
  end
  let(:mp1) { mpt1.market_prices.first }
  let!(:mpt2) do
    create(:market_price_time, time: Time.zone.now + 2.minutes, market_prices: [
      build(:market_price, market_runner: r1),
      build(:market_price, market_runner: runner2),
    ])
  end
  let(:mp2) { mpt2.market_prices.first }

  it "produces market chart data" do
    expect(helper.market_chart_data([market1]).map { |c| c.transform_values(&:to_s) })
      .to eq([
        { time: mpt1.time.to_s, r1.id => mp1.back1price.to_s },
        { time: mpt2.time.to_s, r1.id => mp2.back1price.to_s },
      ])
  end

  it "produces market ykeys" do
    expect(helper.bet_markets_ykeys([market1]))
      .to eq([r1.id])
  end

  it "produces market labels" do
    expect(helper.bet_markets_labels([market1.reload]))
      .to eq(["Market One (Runner)"])
  end

  describe "#bet_market_data" do
    let(:target) { helper.bet_market_data([market1]) }
    let(:labels) { target.map { |x| x.fetch(:label) } }
    let(:prices) { target.map { |x| x.fetch(:prices) } }

    it "has labels" do
      expect(labels).to eq(["Market One (Runner)"])
    end

    it "produces a sensible data stream" do
      expect(prices.map { |hash| hash.transform_keys(&:to_s) })
      .to eq([{ mpt1.time.to_s => mp1.back1price, mpt2.time.to_s => mp2.back1price }])
    end
  end
end

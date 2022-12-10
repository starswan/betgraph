# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Match do
  before do
    create(:season, calendar: calendar)
    create(:market_price_time,
           market_prices: [
             build(:market_price, market_runner: bet_market.market_runners.first),
             build(:market_price, market_runner: bet_market.market_runners.second),
           ])
    create(:market_price_time,
           market_prices: [
             build(:market_price, market_runner: bet_market.market_runners.first),
             build(:market_price, market_runner: bet_market.market_runners.second),
           ])
  end

  let(:sport) { create(:sport, basket_rules: [build(:basket_rule, name: "Rule 1")]) }
  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }
  let!(:hometeam) { create(:team, sport: sport) }
  let!(:awayteam) { create(:team, sport: sport) }
  let(:menu_path) { create(:menu_path, sport: sport) }
  let(:soccer_match) do
    create(:soccer_match, live_priced: true,
                          division: division,
                          name: "#{hometeam.name} v #{awayteam.name}").tap do |m|
      m.update!(scorers: [
        build(:scorer, team: hometeam, goaltime: 6),
        build(:scorer, team: hometeam, goaltime: 8),
      ])
    end
  end
  let!(:bet_market) do
    create(:bet_market, match: soccer_match, market_runners: [
      build(:market_runner, trades: [build(:trade, side: "L")]),
      build(:market_runner, trades: [build(:trade)]),
      build(:market_runner),
    ])
  end

  let(:teamless_match) { build(:soccer_match) }

  it "matches have home and away teams" do
    expect(soccer_match.hometeam).to eq(hometeam)
    expect(soccer_match.awayteam).to eq(awayteam)
  end

  it "matches can assign home and away teams" do
    teamless_match.hometeam = hometeam
    teamless_match.awayteam = awayteam
  end

  it "activelive" do
    expect(described_class.activelive).to eq([soccer_match])
  end

  it "homegoals" do
    expect(soccer_match.homegoals(10)).to eq(2)
  end

  it "awaygoals" do
    expect(soccer_match.awaygoals(10)).to eq(0)
  end

  it "homescorercount" do
    expect(soccer_match.homescorercount).to eq(2)
  end

  it "awayscorercount" do
    expect(soccer_match.awayscorercount).to eq(0)
  end

  it "sport" do
    expect(soccer_match.sport).to eq(sport)
  end
end

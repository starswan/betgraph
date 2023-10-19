# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe MarketRunner do
  before do
    create(:season, calendar: calendar)
  end

  describe "creating runner type" do
    let(:sport) { create(:sport) }
    let(:market_type) { create(:betfair_market_type, sport: sport) }
    let(:hometeam) do
      create(:team, sport: sport, team_names: [
        build(:team_name, name: "Milan"), build(:team_name, name: "AC Milan")
      ])
    end
    let(:awayteam) { create(:team, sport: sport, team_names: [build(:team_name)]) }
    let(:calendar) { create(:calendar, sport: sport) }
    let(:division) { create(:division, calendar: calendar) }
    let(:soccermatch) do
      create(:soccer_match, division: division,
                            name: "#{hometeam.name} v #{awayteam.name}")
    end

    let(:market) { create(:bet_market, match: soccermatch, betfair_market_type: market_type) }
    let(:runner) { create(:market_runner, bet_market: market, description: hometeam.team_names.last.name) }
    let(:runner2) { create(:market_runner, bet_market: market, description: hometeam.team_names.first.name) }

    before do
      create(:betfair_runner_type, name: '#{hometeam}', betfair_market_type: market_type)
    end

    it "matches hometeam" do
      expect(runner.betfair_runner_type.name).to eq('#{hometeam}')
    end

    it "also matches hometeam" do
      expect(runner2.betfair_runner_type.name).to eq('#{hometeam}')
    end
  end

  context "new factory" do
    let(:sport) { create(:soccer) }
    let(:calendar) { create(:calendar, sport: sport) }
    let(:division) { create(:division, calendar: calendar) }
    let(:hometeam) { create(:team) }
    let(:awayteam) { create(:team) }
    let(:menu_path) { create(:menu_path, sport: sport) }
    let(:soccermatch) do
      create(:soccer_match, live_priced: true, division: division,
                            name: "#{hometeam.name} v #{awayteam.name}")
    end
    let(:match_two) do
      create(:soccer_match, live_priced: true, division: division,
                            name: "#{awayteam.name} v #{hometeam.name}")
    end

    let(:market) { create(:bet_market, :overunder, match: soccermatch) }
    let(:mpt) { create(:market_price_time) }
    let(:runner) { create(:market_runner, bet_market: market, prices: [build(:price, market_price_time: mpt, created_at: mpt.time)]) }

    let(:bm2) { create(:bet_market, active: true, match: soccermatch) }
    let(:handicap_runner) { create(:market_runner, bet_market: bm2) }

    before do
      create(:betfair_market_type, name: "Correct Score", sport: sport)
      create(:betfair_market_type, name: market.name, sport: sport)
      create(:betfair_market_type, name: bm2.name, sport: sport)

      create(:market_runner, bet_market: bm2)
    end

    it "New runner type creates new BetfairRunnerType" do
      expect {
        bm2.market_runners.create!(selectionId: 1,
                                   asianLineId: 0,
                                   description: "Hello")
      }.to change(BetfairRunnerType, :count).by(1)
    end

    it "reversed prices" do
      expect(runner.prices.count).to be_positive
      expect(runner.prices.reverse).to eq(runner.reversedprices)
    end
  end
end

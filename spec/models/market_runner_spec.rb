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
    let(:sport) { create(:sport, name: "Soccer", basket_rules: [build(:basket_rule, name: "Rule 1")]) }
    # let(:sport) { sports(:one) }
    let(:calendar) { create(:calendar, sport: sport) }
    let(:division) { create(:division, calendar: calendar) }
    let(:hometeam) { create(:team) }
    let(:awayteam) { create(:team) }
    let(:menu_path) { create(:menu_path, sport: sport) }
    let(:soccermatch) do
      create(:soccer_match, live_priced: true, division: division,
                            name: "#{hometeam.name} v #{awayteam.name}")
    end

    let(:market) { create(:bet_market, match: soccermatch) }
    let(:runner) { create(:market_runner, bet_market: market) }

    let(:bm2) { create(:bet_market, active: true, match: soccermatch) }
    let(:handicap_runner) { create(:market_runner, bet_market: bm2) }

    before do
      create(:betfair_market_type, name: "Correct Score", sport: sport)

      create(:market_price_time,
             market_prices: [build(:market_price, market_runner: runner)])
      create(:market_runner, bet_market: bm2)
    end

    it "New runner type creates new BetfairRunnerType" do
      expect {
        bm2.market_runners.create!(selectionId: 1,
                                   asianLineId: 0,
                                   description: "Hello")
      }.to change(BetfairRunnerType, :count).by(1)
    end

    it "old runner type does not create new BetfairRunnerType" do
      expect {
        market.market_runners.create!(selectionId: 2,
                                      asianLineId: 0,
                                      description: runner.description)
      }.not_to change(BetfairRunnerType, :count)
    end

    it "runner update" do
      expect(runner.save).to eq(true)
      expect(runner.runnername).to start_with("Runner ")
      expect(runner.runner_value(0, 0)).to eq(1)
    end

    it "all runners can be valued" do
      expect(runner.runner_value(0, 0)).to eq(1)
      expect(handicap_runner.runner_value(0, 0)).to eq(1)
    end

    it "reversed prices" do
      expect(runner.market_prices.count).to be_positive
      expect(runner.market_prices.reverse).to eq(runner.reversedprices)
    end
  end
end

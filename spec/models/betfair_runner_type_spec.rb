# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe BetfairRunnerType do
  before do
    create(:season, calendar: calendar)
  end

  let(:sport) { create(:soccer) }
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

  let(:runner_type) { create(:betfair_runner_type, betfair_market_type: market_type) }
  let(:bet_market) { create(:bet_market, match: soccermatch) }

  it "runner type produces sensible valuer" do
    expect(runner_type.valuer.class).to eq(Soccer::CorrectScore)
  end

  it "valuer with handicap" do
    expect(bet_market.market_value(bet_market.time, 0, 0)).to eq(0)
  end

  # it "runner types produced for new runners" do
  #   expect {
  #     bet_market.market_runners.create! selectionId: 1, description: "One", asianLineId: 1
  #     bet_market.market_runners.create! selectionId: 2, description: "Two", asianLineId: 2
  #   }.to change(described_class, :count).by(2)
  # end
end

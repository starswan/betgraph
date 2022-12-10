# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe SeasonsHelper, type: :helper do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }

  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let!(:football_division) { create(:football_division, division: division) }
  let(:hometeam) { create(:team) }
  let(:awayteam) { create(:team) }
  let(:menu_path) { create(:menu_path, sport: sport) }
  let(:soccermatch) { create(:soccer_match, live_priced: true, division: division, hometeam: hometeam, awayteam: awayteam) }
  let!(:result) { create(:result, match: soccermatch) }

  it "I have no idea what this code really does" do
    expect((helper.match_display soccermatch, "nilnilscore").colour).to eq("green")
  end
end

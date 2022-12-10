# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe BetMarkets::TradesController, type: :controller do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }

  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:hometeam) { create(:team, sport: sport) }
  let(:awayteam) { create(:team, sport: sport) }
  let(:menu_path) { create(:menu_path, sport: sport) }
  let!(:soccermatch) { create(:soccer_match, live_priced: true, division: division, hometeam: hometeam, awayteam: awayteam) }

  let!(:bet_market) { create(:bet_market, match: soccermatch) }

  it "gets index" do
    get :index, params: { bet_market_id: bet_market }

    expect(response.status).to eq(200)
    expect(assigns(:trades)).not_to be_nil
  end
end

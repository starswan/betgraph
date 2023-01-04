# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe SoccerMatches::BetMarketsController, type: :controller do
  let(:sport) do
    create(:sport,
           # name: 'Soccer',
           basket_rules: [build(:basket_rule, name: "Rule 1")],
           betfair_market_types: [
             build(:betfair_market_type, name: "The Market Type"),
             build(:betfair_market_type, name: "First Half Goals", valuer: "FirstHalfGoals"),
           ])
  end
  let(:market_type) { sport.betfair_market_types.first }
  let(:half_time_bmt) { sport.betfair_market_types.second }
  let(:calendar) { create(:calendar, sport: sport) }
  let!(:season) { create(:season, calendar: calendar) }
  let(:division) { create(:division, calendar: calendar) }
  let(:soccermatch) do
    create(:soccer_match,
           division: division)
  end
  let!(:bet_market) { create(:bet_market, active: true, time: Time.zone.now + 10.minutes, match: soccermatch) }
  let!(:half_time_market) do
    create(:bet_market,
           name: "First Half Goals",
           match: soccermatch, time: Time.zone.now + 10.minutes, active: true)
  end

  it "index gets non half time markets" do
    get :index, params: { soccer_match_id: soccermatch.id }

    expect(response.status).to eq(200)
    expect(assigns(:bet_markets)).to match_array(soccermatch.bet_markets.full_time)
  end

  it "gets half-time markets" do
    get :half_time, params: { soccer_match_id: soccermatch.id }

    expect(response).to be_successful
    expect(assigns(:bet_markets)).to match_array [half_time_market]
  end
end

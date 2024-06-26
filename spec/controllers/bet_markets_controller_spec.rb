# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe BetMarketsController, type: :controller do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }
  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:hometeam) { create(:team, sport: sport) }
  let(:awayteam) { create(:team, sport: sport) }
  let(:menu_path) { create(:menu_path, sport: sport) }
  let!(:soccermatch) do
    create(:soccer_match, live_priced: true, division: division,
                          name: "#{hometeam.name} v #{awayteam.name}",
                          hometeam: hometeam, awayteam: awayteam)
  end

  let(:bet_market) { soccermatch.bet_markets.last }

  before do
    create(:bet_market, match: soccermatch, name: market_type.name)
  end

  render_views

  it "gets index" do
    get :index, params: { match_id: soccermatch }
    assert_response :success
    expect(assigns(:bet_markets)).not_to be_nil
  end

  it "shows bet_market" do
    get :show, params: { id: bet_market }
    assert_response :success
  end

  it "gets edit" do
    get :edit, params: { id: bet_market }
    assert_response :success
  end

  it "updates bet_market" do
    put :update, params: { id: bet_market, bet_market: { description: "something" } }
    assert_redirected_to bet_market_path(assigns(:bet_market))
  end

  it "does not update when it errors" do
    put :update, params: { id: bet_market, bet_market: { status: "something" } }
    expect(bet_market.reload.status).to eq("ACTIVE")
  end

  it "destroys bet_market" do
    expect {
      delete :destroy, params: { id: bet_market }
    }.to change { BetMarket.where(active: true).count }.by(-1)

    assert_redirected_to soccer_match_bet_markets_path(soccermatch)
  end
end

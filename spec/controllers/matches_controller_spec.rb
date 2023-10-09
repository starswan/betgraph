# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe MatchesController, type: :controller do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }

  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:hometeam) { create(:team, sport: sport) }
  let(:awayteam) { create(:team, sport: sport) }
  let(:menu_path) { create(:menu_path, sport: sport) }
  let(:soccermatch) do
    create(:soccer_match,
           division: division,
           kickofftime: Time.zone.local(2017, 11, 1, 15, 0, 0),
           name: "#{hometeam.name} v #{awayteam.name}")
  end
  let!(:bet_market) { create(:bet_market, active: true, time: Time.zone.now + 10.minutes, match: soccermatch) }

  it "gets index with date" do
    get :index, params: { division_id: division, date: soccermatch.kickofftime.to_date }
    assert_response :success
    expect(assigns(:matches)).to eq([soccermatch])
  end

  it "gets index" do
    get :index, params: { division_id: division }
    assert_response :success
    expect(assigns(:matches)).to match_array([soccermatch])
  end

  it "gets index priced only" do
    get :index, params: { division_id: division, priced_only: true }
    assert_response :success
    expect(assigns(:matches)).to match_array([])
  end

  it "gets index xml" do
    get :index, params: { division_id: division }, format: :xml
    assert_response :success
    expect(assigns(:matches)).to match_array([soccermatch])
  end

  it "future should show only unplayed matches" do
    get :future
    assert_response :success
    expect(assigns(:matches).map(&:name)).to eq([])
  end

  it "show return active matches" do
    get :active
    assert_response :success
    expect(assigns(:matches)).to eq([soccermatch])
  end

  it "creates match" do
    expect {
      post :create, params: {
        division_id: division,
        match: {
          kickofftime: Time.zone.now,
          type: "SoccerMatch",
          name: "Fred v Kim",
        },
      }
    }.to change(Match, :count).by(1)

    assert_redirected_to soccer_match_path(assigns(:match))
  end

  it "creates match via XML" do
    expect {
      post :create, params: {
        division_id: division,
        match: {
          kickofftime: Time.zone.now,
          type: "SoccerMatch",
          name: "Fred v Bill",
        },
      }, format: :xml
      assert_response :success
    }.to change(Match, :count).by(1)
  end

  it "shows match" do
    get :show, params: { id: soccermatch }
    assert_response :success
  end

  it "gets edit" do
    get :edit, params: { id: soccermatch }
    assert_response :success
  end

  it "updates match" do
    expect(soccermatch.live_priced).to eq(false)
    put :update, params: { id: soccermatch, match: { live_priced: true } }
    assert_redirected_to soccer_match_path(assigns(:match))
    expect(soccermatch.reload.live_priced).to eq(true)
  end

  it "destroys match" do
    # ActiveJob - tests now run delayed code too.
    expect {
      delete :destroy, params: { id: soccermatch }
    }.to change(Match, :count).by(-1)

    assert_redirected_to division_path(division)
  end
end

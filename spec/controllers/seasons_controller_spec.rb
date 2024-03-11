#
# $Id$
#
require "rails_helper"

RSpec.describe SeasonsController, type: :controller do
  let(:sport) { create(:soccer) }
  let!(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }

  let!(:first_season) { create(:season, :first, calendar: calendar) }
  let!(:season) { create(:season, startdate: Time.zone.today, calendar: calendar) }
  let!(:final_season) { create(:season, :final, calendar: calendar) }
  let!(:sm_list) { create_list(:soccer_match, 1, division: division, kickofftime: season.startdate + 2.days + 15.hours) }

  describe "#show" do
    before do
      create(:soccer_match, division: division, kickofftime: final_season.startdate + 1.day)
      get :show, params: { sport_id: sport.id, season_id: season.id, threshold: 11 }
    end

    it "is successful" do
      expect(response).to be_successful
    end

    it "returns the matches" do
      expect(assigns(:football_matches)).to match_array(sm_list)
    end
  end

  it "gets index" do
    get :index, params: { sport_id: sport.id }
    assert_response :success
    expect(assigns(:seasons)).not_to be_nil
  end

  it "gets new" do
    get :new, params: { sport_id: sport.id, calendar_id: calendar.id }
    assert_response :success
  end

  it "creates football_season" do
    expect {
      post :create, params: { sport_id: sport.id, calendar_id: calendar.id, season: { name: "Current" } }
    }.to change(Season, :count).by(1)

    assert_redirected_to calendar_seasons_path(calendar)
  end

  it "shows current football season" do
    Timecop.travel Date.new(2009, 9, 1) do
      get :show, params: { sport_id: sport.id, season_id: season.to_param, threshold: 7 }
      assert_response :success
    end
  end

  it "gets edit" do
    get :edit, params: { calendar_id: calendar.id, id: season.to_param }
    assert_response :success
  end

  it "updates football_season" do
    put :update, params: { calendar_id: calendar.id, id: season.to_param, season: { name: "h" } }
    # assert_redirected_to football_season_path(assigns(:football_season))
  end

  it "destroys football_season" do
    expect {
      delete :destroy, params: { calendar_id: calendar.id, id: season.to_param }
    }.to change(Season, :count).by(-1)

    assert_redirected_to sport_seasons_path sport
  end
end

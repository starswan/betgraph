# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe TennisMatchesController, type: :controller do
  before do
    tennis = create(:sport, name: "Tennis", calendars: build_list(:calendar, 1))
    calendar = tennis.calendars.first
    season = create(:season, calendar: calendar)
    tplayer = create(:team, sport: tennis)
    tdiv = create(:division, calendar: calendar)
    create(:tennis_match, season: season, division: tdiv, venue: tplayer)
  end

  let(:division) { Division.last }
  let(:tennis_match) { Match.last }

  it "gets index" do
    get :index, params: { division_id: division }
    assert_response :success
  end

  it "gets new" do
    get :new, params: { division_id: division }
    assert_response :success
  end

  it "gets show" do
    get :show, params: { id: tennis_match.id }
    assert_response :success
  end

  it "gets show with offset" do
    get :show, params: { id: tennis_match, offset: 1 }
    assert_response :success
  end

  it "is able to create" do
    expect {
      post :create, params: { division_id: division,
                              match: { kickofftime: Time.zone.now,
                                       name: "Fred v Jim" } }
      # :match_teams => [ teams(:one), teams(:two) ]
      # assert_redirected_to division_match_path(@division, assigns(:tennis_match))
      # assert_response :redirect
    }.to change(TennisMatch, :count).by(1)
  end
end

# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe TeamsController, type: :controller do
  before do
    create(:season)
    create(:team, name: "Team", sport: sport, created_at: Time.zone.now - 1.hour)
    create(:team, name: "Other", sport: sport, created_at: Time.zone.now - 2.hours)
    create(:team, name: "Three", sport: sport, created_at: Time.zone.now - 3.hours)
  end

  let(:sport) { create(:sport, basket_rules: [build(:basket_rule, name: "Rule 1")]) }
  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }

  let(:team) { TeamName.find_by!(name: "Team").team }
  let(:team_three) { TeamName.find_by!(name: "Three").team }

  describe "index" do
    it "defaults to name sorting" do
      get :index, params: { sport_id: sport }
      assert_response :success
      expect(assigns(:teams).map(&:name)).to eq(%w[Other Team Three])
    end

    it "can be name sorted" do
      get :index, params: { sport_id: sport, sort_by: "name" }
      assert_response :success
      expect(assigns(:teams).map(&:name)).to eq(%w[Other Team Three])
    end

    it "can be created_at sorted" do
      get :index, params: { sport_id: sport, sort_by: "created_at" }
      assert_response :success
      expect(assigns(:teams).map(&:name)).to eq(%w[Team Other Three])
    end

    it "can be matches_count sorted" do
      get :index, params: { sport_id: sport, sort_by: "matches_count" }
      assert_response :success
      expect(assigns(:teams).map(&:name)).to eq(%w[Team Other Three])
    end
  end

  it "shows team" do
    get :show, params: { id: team }
    assert_response :success
  end

  it "gets edit" do
    get :edit, params: { id: team }
    assert_response :success
  end

  # This test and code is now in team names controller
  # describe "update" do
  #   let(:otherteam)  { TeamName.find_by!(name: "Other").team }
  #   let!(:match_one) { create(:soccer_match, name: "#{otherteam.name} v #{team_three.name}", division: division) }
  #   # I think this should assert some other stuff too...!
  #
  #   it "updates team, delete otherteam and shuffle matches and venues around" do
  #     expect {
  #       put :update, params: { other_team: { other_team_id: otherteam }, id: team, team: {}, sport_id: sport }
  #       assert_redirected_to sport_team_path(sport, assigns(:team))
  #     }.to change(Team, :count).by(-1)
  #     expect(match_one.reload.venue).to eq(team)
  #     expect(match_one.reload.teams.map(&:name)).to match_array %w[Other Three]
  #   end
  # end

  it "destroys team" do
    expect {
      delete :destroy, params: { id: team_three }
    }.to change(Team, :count).by(-1)
  end
end

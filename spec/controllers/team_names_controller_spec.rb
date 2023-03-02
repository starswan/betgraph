# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe TeamNamesController, type: :controller do
  before do
    create(:team, sport: sport, team_names: build_list(:team_name, 1, name: "MyTeam"))
  end

  let(:sport) { create(:sport, basket_rules: [build(:basket_rule, name: "Rule 1")]) }
  let(:my_team_name) { TeamName.find_by!(name: "MyTeam") }
  let(:my_team) { my_team_name.team }

  it "gets index" do
    get :index, params: { team_id: my_team.to_param }
    assert_response :success
    expect(assigns(:team_names)).to eq(my_team.team_names)
  end

  it "gets new" do
    get :new, params: { team_id: my_team.to_param }
    assert_response :success
  end

  it "creates team_name" do
    expect {
      post :create, params: {  team_id: my_team.to_param, team_name: { name: "Fred" } }
    }.to change(TeamName, :count).by(1)

    assert_redirected_to team_team_name_path(my_team, assigns(:team_name))
  end

  it "shows team_name" do
    get :show, params: { team_id: my_team.to_param, id: my_team.team_names.first }
    assert_response :success
  end

  it "gets edit" do
    get :edit, params: { team_id: my_team.to_param, id: my_team.team_names.first }
    assert_response :success
  end

  describe "#update" do
    before do
      calendar = create(:calendar, sport: sport)
      division = create(:division, calendar: calendar)

      create(:team, sport: sport, team_names: build_list(:team_name, 1, name: "Other"))
      team_three = create(:team, sport: sport, team_names: build_list(:team_name, 1, name: "Three"))
      team4 = create(:team, team_names: build_list(:team_name, 1, name: "Four"))
      create(:soccer_match, name: "#{otherteam.name} v #{team_three.name}", division: division)
      create(:soccer_match, name: "#{team4.name} v #{otherteam.name}", division: division)
    end

    let(:otherteam) { TeamName.find_by!(name: "Other").team }
    let(:match_one) { SoccerMatch.first }
    # let(:match_two) { SoccerMatch.last }
    # I think this should assert some other stuff too...!

    it "updates team, delete otherteam and shuffle matches and venues around" do
      expect {
        put :update, params: { team_name: { team_id: otherteam.id }, id: my_team_name.id }
        # put :update, params: { other_team: { other_team_id: otherteam }, id: team, team: {}, sport_id: sport }
        # assert_redirected_to sport_team_path(sport, assigns(:team))
        # assert_redirected_to team_path(assigns(:team))
        expect(response).to have_http_status(:redirect)
      }.to change(Team, :count).by(-1)
      expect(match_one.reload.venue).to eq(my_team)
      expect(match_one.reload.teams.map(&:name)).to match_array %w[Other Three]
    end
  end

  it "destroys team_name" do
    expect {
      delete :destroy, params: { team_id: my_team.to_param, id: my_team.team_names.first }
    }.to change(TeamName, :count).by(-1)

    assert_redirected_to team_team_names_path(my_team)
  end
end

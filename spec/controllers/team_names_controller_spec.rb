# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe TeamNamesController, type: :controller do
  before do
    create(:team, sport: build(:sport), team_names: [build(:team_name), build(:team_name)])
  end

  let!(:my_team) { create(:team, sport: build(:sport), team_names: [build(:team_name), build(:team_name)]) }

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

  it "updates team_name" do
    put :update, params: { team_id: my_team.to_param, id: my_team.team_names.first, team_name: { name: "Bill" } }
    # assert_redirected_to team_name_path(assigns(:team_name))
  end

  it "destroys team_name" do
    expect {
      delete :destroy, params: { team_id: my_team.to_param, id: my_team.team_names.first }
    }.to change(TeamName, :count).by(-1)

    assert_redirected_to team_team_names_path(my_team)
  end
end

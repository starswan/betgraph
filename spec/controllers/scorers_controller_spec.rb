# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe ScorersController, type: :controller do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }

  let!(:amatch) { create(:soccer_match, division: division) }
  let!(:scorer) { create(:scorer, match: amatch, team: amatch.hometeam) }

  it "gets index" do
    get :index, params: { match_id: amatch }
    assert_response :success
    expect(assigns(:scorers)).not_to be_nil
  end

  it "gets new" do
    get :new, params: { match_id: amatch }
    assert_response :success
  end

  it "creates scorer" do
    expect {
      post :create, params: { match_id: amatch, scorer: { name: "name", team_id: amatch.hometeam, goaltime: 47 } }
    }.to change(Scorer, :count).by(1)

    # assert_redirected_to scorer_path(assigns(:scorer))
  end

  it "shows scorer" do
    get :show, params: { id: scorer.to_param }
    assert_response :success
  end

  it "gets edit" do
    get :edit, params: { id: scorer.to_param }
    assert_response :success
  end

  it "updates scorer" do
    put :update, params: { id: scorer.to_param, scorer: { name: "name", goaltime: 25 } }
    # assert_redirected_to match_scorer_path(amatch, assigns(:scorer))
  end

  it "destroys scorer" do
    expect {
      delete :destroy, params: { id: scorer.to_param }
    }.to change(Scorer, :count).by(-1)

    assert_redirected_to match_scorers_path(amatch)
  end
end

# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

module SoccerMatches
  RSpec.describe ScorersController, type: :controller do
    let(:season) { create(:season) }
    let(:division) { create(:division, calendar: season.calendar) }
    let(:sport) { season.calendar.sport }

    let!(:amatch) { create(:soccer_match, division: division) }
    let!(:scorer) { create(:scorer, match: amatch, team: amatch.hometeam) }

    it "gets index" do
      get :index, params: { soccer_match_id: amatch }
      assert_response :success
      expect(assigns(:scorers)).not_to be_nil
    end

    it "gets new" do
      get :new, params: { soccer_match_id: amatch }
      assert_response :success
    end

    it "errors on create" do
      post :create, params: { soccer_match_id: amatch, scorer: { name: "", team_id: amatch.hometeam, goaltime: 47 } }
      assert_template 'new'
    end

    it "creates scorer" do
      expect {
        post :create, params: { soccer_match_id: amatch, scorer: { name: "name", team_id: amatch.hometeam, goaltime: 47 } }
      }.to change(Scorer, :count).by(1)

      # assert_redirected_to scorer_path(assigns(:scorer))
    end

    it "gets edit" do
      get :edit, params: { soccer_match_id: amatch, id: scorer.to_param }
      assert_response :success
    end

    it "updates scorer" do
      put :update, params: { soccer_match_id: amatch, id: scorer.to_param, scorer: { name: "name", goaltime: 25 } }
      # assert_redirected_to match_scorer_path(amatch, assigns(:scorer))
    end

    it "errors on update" do
      put :update, params: { soccer_match_id: amatch, id: scorer.to_param, scorer: { name: "", goaltime: 25 } }
      assert_template 'edit'
    end

    it "destroys scorer" do
      expect {
        delete :destroy, params: { soccer_match_id: amatch, id: scorer.to_param }
      }.to change(Scorer, :count).by(-1)

      assert_redirected_to soccer_match_scorers_path(amatch)
    end
  end
end

# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe ResultsController, type: :controller do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }

  let(:match) { create(:soccer_match, division: division) }

  context "with result" do
    let!(:result) { create(:result, match: match) }

    it "gets index" do
      get :index, params: { date: "2008-05-10" }
      assert_response :success
      expect(assigns(:results)).not_to be_nil
    end

    it "gets new" do
      get :new, params: { match_id: match }
      assert_response :success
    end

    it "shows result" do
      get :show, params: { id: result }
      assert_response :success
    end

    it "gets edit" do
      get :edit, params: { id: result }
      assert_response :success
    end

    it "updates result" do
      put :update, params: { id: result, result: { homescore: 4 } }
      assert_redirected_to result_path(assigns(:result))
    end

    it "does not update result with error" do
      put :update, params: { id: result, result: { homescore: "" } }
      expect(assigns(:result).errors.full_messages).to eq ["Homescore can't be blank"]
    end

    it "destroys result" do
      expect {
        delete :destroy, params: { id: result }
      }.to change(Result, :count).by(-1)

      assert_redirected_to results_path
    end
  end

  it "creates result" do
    expect {
      post :create, params: { match_id: match, result: { homescore: 1, awayscore: 5 } }
    }.to change(Result, :count).by(1)

    assert_redirected_to result_path(assigns(:result))
  end

  it "does not create result with error" do
    expect {
      post :create, params: { match_id: match, result: { homescore: 1 } }
    }.to change(Result, :count).by(0)
  end
end

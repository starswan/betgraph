# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe SportsController, type: :controller do
  let!(:sport) { create(:sport) }

  it "gets index" do
    get :index
    assert_response :success
    expect(assigns(:sports)).not_to be_nil
  end

  it "shows sport" do
    get :show, params: { id: sport.id }
    assert_response :success
  end

  it "gets edit" do
    get :edit, params: { id: sport.id }
    assert_response :success
  end

  it "updates sport" do
    put :update, params: { id: sport.id, sport: { name: "thing" } }
    assert_redirected_to sport_path(assigns(:sport))
  end

  it "destroys sport" do
    expect {
      delete :destroy, params: { id: sport.id }
    }.to change(Sport, :count).by(-1)

    assert_redirected_to sports_path
  end
end

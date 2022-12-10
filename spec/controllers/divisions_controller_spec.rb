# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe DivisionsController, type: :controller do
  let(:sport) { create(:sport, basket_rules: [build(:basket_rule, name: "Rule 1")]) }
  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:calendar) { create(:calendar, sport: sport) }
  let!(:division) { create(:division, calendar: calendar) }

  it "should_get_index" do
    get :index, params: { sport_id: sport }
    assert_response :success
    expect(assigns(:divisions)).not_to be_nil
  end

  it "should_get_new" do
    get :new, params: { sport_id: sport }
    assert_response :success
  end

  it "should_create_division" do
    expect {
      post :create, params: { division: { name: "Test Division" }, sport_id: sport }
    }.to change(Division, :count).by(1)

    assert_redirected_to division_path(assigns(:division))
  end

  it "should_show_division" do
    get :show, params: { id: division }
    assert_response :success
  end

  it "should_get_edit" do
    get :edit, params: { id: division }
    assert_response :success
  end

  it "should_update_division" do
    put :update, params: { id: division, division: { name: "a division" } }
    assert_redirected_to division_path(assigns(:division))
  end

  it "should_destroy_division" do
    expect {
      delete :destroy, params: { sport_id: sport, id: division }
    }.to change(Division, :count).by(-1)

    # assert_redirected_to divisions_path
  end
end

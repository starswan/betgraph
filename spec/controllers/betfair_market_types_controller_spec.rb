# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe BetfairMarketTypesController, type: :controller do
  let(:sport) { create(:sport, basket_rules: [build(:basket_rule, name: "Rule 1")]) }
  let(:market_type) { sport.betfair_market_types.first }

  before { create(:betfair_market_type, name: "The Market Type", sport: sport) }

  it "should_get_index" do
    get :index, params: { sport_id: sport }
    assert_response :success
    expect(assigns(:betfair_market_types)).not_to be_nil
  end

  it "shows betfair market_type" do
    get :show, params: { id: market_type, sport_id: sport }
    assert_response :success
  end

  it "should_get_edit" do
    get :edit, params: { id: market_type, sport_id: sport }
    assert_response :success
  end

  it "should_update_betfair_market_type" do
    put :update, params: { id: market_type, sport_id: sport, betfair_market_type: { active: false } }
  end

  it "does not update_betfair_market_type on error" do
    put :update, params: { id: market_type, sport_id: sport, betfair_market_type: { name: "" } }
    expect(assigns(:betfair_market_type).errors.full_messages).to eq ["Name can't be blank"]
  end

  it "should_destroy_betfair_market_type" do
    expect {
      delete :destroy, params: { id: market_type, sport_id: sport }
    }.to change(BetfairMarketType, :count).by(-1)

    assert_redirected_to sport_betfair_market_types_path(sport)
  end
end

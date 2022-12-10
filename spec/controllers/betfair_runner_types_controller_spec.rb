# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe BetfairRunnerTypesController, type: :controller do
  let(:sport) { create(:sport, basket_rules: [build(:basket_rule, name: "Rule 1")]) }
  before { create(:betfair_market_type, name: "The Market Type", sport: sport) }

  let(:market_type) { sport.betfair_market_types.first }
  let!(:runner_type) { create(:betfair_runner_type, betfair_market_type: market_type) }

  it "should_get_index" do
    get :index, params: { betfair_market_type_id: market_type }
    assert_response :success
    expect(assigns(:betfair_runner_types)).not_to be_nil
  end

  it "should_get_new" do
    get :new, params: { betfair_market_type_id: market_type }
    assert_response :success
  end

  it "should_create_betfair_runner_type" do
    expect {
      post :create, params: { betfair_runner_type: { name: "Runner Type",
                                                     runnertype: "RunnerType",
                                                     runnerhomevalue: 34.25,
                                                     runnerawayvalue: 27.75 },
                              betfair_market_type_id: market_type }
    }.to change(BetfairRunnerType, :count).by(1)

    # assert_redirected_to betfair_market_type_betfair_runner_type_path(assigns([:betfair_market_type,:betfair_runner_type]))
  end

  it "should_show_betfair_runner_type" do
    get :show, params: { id: runner_type.id, betfair_market_type_id: runner_type.betfair_market_type }
    assert_response :success
  end

  it "should_get_edit" do
    get :edit, params: { id: runner_type.id, betfair_market_type_id: runner_type.betfair_market_type }
    assert_response :success
  end

  it "should_update_betfair_runner_type" do
    put :update, params: { id: runner_type.id,
                           betfair_market_type_id: runner_type.betfair_market_type,
                           betfair_runner_type: { name: runner_type.name } }
    # assert_redirected_to betfair_market_type_betfair_runner_type_path(assigns([:betfair_market_type,:betfair_runner_type]))
  end

  it "should_destroy_betfair_runner_type" do
    expect {
      delete :destroy, params: { id: runner_type.id, betfair_market_type_id: runner_type.betfair_market_type.id }
    }.to change(BetfairRunnerType, :count).by(-1)

    # assert_redirected_to runner_type.betfair_market_type
  end
end

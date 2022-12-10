# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe BasketRulesController, type: :controller do
  before do
    create(:sport, basket_rules: [build(:basket_rule, name: "Rule 1")])
  end

  let(:sport) { Sport.last }
  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:division) { create(:division, sport: sport) }
  let(:hometeam) { create(:team) }
  let(:awayteam) { create(:team) }
  let(:menu_path) { create(:menu_path, sport: sport) }
  let(:soccermatch) { create(:soccer_match, live_priced: true, division: division, hometeam: hometeam, awayteam: awayteam) }
  let(:basket_rule) { sport.basket_rules.first }
  let(:runner_type) { create(:betfair_runner_type, betfair_market_type: market_type) }

  it "gets index" do
    get :index, params: { sport_id: sport }
    assert_response :success
    expect(assigns(:basket_rules)).not_to be_nil
  end

  it "gets new" do
    get :new, params: { sport_id: sport }
    assert_response :success
  end

  it "creates basket rule" do
    expect {
      post :create, params: { sport_id: sport, basket_rule: { name: "think" } }
    }.to change(BasketRule, :count).by(1)

    # assert_redirected_to basket_path(assigns(:basket))
  end

  it "shows basket" do
    get :show, params: { id: basket_rule }
    assert_response :success
  end

  it "gets edit" do
    get :edit, params: { id: basket_rule }
    assert_response :success
  end

  it "updates basket" do
    put :update, params: { id: basket_rule, basket_rule: { name: "different" } }
    assert_redirected_to basket_rule_path(assigns(:basket_rule))
  end

  it "destroys basket" do
    expect {
      delete :destroy, params: { id: basket_rule }
    }.to change(BasketRule, :count).by(-1)

    assert_redirected_to sport_basket_rules_path(sport)
  end
end

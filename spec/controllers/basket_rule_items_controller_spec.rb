# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe BasketRuleItemsController, type: :controller do
  let(:sport) { create(:sport, basket_rules: [build(:basket_rule, name: "Rule 1")]) }
  let(:basket_rule_item) { basket_rule.basket_rule_items.first }
  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:division) { create(:division, sport: sport) }
  let(:hometeam) { create(:team) }
  let(:awayteam) { create(:team) }
  let(:menu_path) { create(:menu_path, sport: sport) }
  let(:soccermatch) { create(:soccer_match, live_priced: true, division: division, hometeam: hometeam, awayteam: awayteam) }
  let(:basket_rule) { sport.basket_rules.first }
  let(:runner_type) { create(:betfair_runner_type, betfair_market_type: market_type) }

  before do
    create(:basket_rule_item, basket_rule: basket_rule, betfair_runner_type: runner_type)
  end

  it "gets index" do
    get :index, params: { basket_rule_id: basket_rule }
    assert_response :success
    expect(assigns(:basket_items)).not_to be_nil
  end

  it "gets new" do
    get :new, params: { basket_rule_id: basket_rule }
    assert_response :success
  end

  it "creates basket_rule_item" do
    expect {
      post :create, params: { basket_rule_id: basket_rule, basket_rule_item: { betfair_runner_type_id: runner_type, weighting: 27 } }
    }.to change(BasketRuleItem, :count).by(1)
  end

  it "does not create basket_rule_item on error" do
    expect {
      post :create, params: { basket_rule_id: basket_rule, basket_rule_item: { betfair_runner_type_id: runner_type } }
    }.to change(BasketRuleItem, :count).by(0)
  end

  it "shows basket_item" do
    get :show, params: { id: basket_rule_item }
    assert_response :success
  end

  it "gets edit" do
    get :edit, params: { id: basket_rule_item }
    assert_response :success
  end

  it "updates basket_item" do
    put :update, params: { id: basket_rule_item,
                           basket_rule_item: { betfair_runner_type_id: runner_type, weighting: 27 } }
  end

  it "does not update basket_rule item on error" do
    put :update, params: { id: basket_rule_item,
                           basket_rule_item: { betfair_runner_type_id: runner_type, weighting: "fred" } }
    expect(assigns(:basket_rule_item).errors.full_messages).to eq ["Weighting is not a number"]
  end

  it "destroys basket_item" do
    expect {
      delete :destroy, params: { id: basket_rule_item }
    }.to change(BasketRuleItem, :count).by(-1)

    # assert_redirected_to basket_items_path
  end
end

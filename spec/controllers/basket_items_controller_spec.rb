# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe BasketItemsController, type: :controller do
  let!(:sport) { create(:sport, calendars: build_list(:calendar, 1)) }
  let(:basket_item) { basket.basket_items.first }
  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:calendar) { sport.calendars.first }
  let(:division) { create(:division, calendar: calendar) }
  let(:hometeam) { create(:team, sport: sport) }
  let(:awayteam) { create(:team, sport: sport) }
  let(:menu_path) { create(:menu_path, sport: sport) }
  let!(:season) { create(:season, calendar: sport.calendars.first) }
  let!(:soccermatch) { create(:soccer_match, live_priced: true, division: division, hometeam: hometeam, awayteam: awayteam) }

  let!(:bet_market) { create(:bet_market, match: soccermatch) }
  let!(:runner) { create(:market_runner, bet_market: bet_market) }
  let(:runner2) { create(:market_runner, bet_market: bet_market) }
  let(:basket) { create(:basket, match: soccermatch) }

  before do
    create(:basket_item, market_runner: runner, basket: basket)
  end

  it "gets index" do
    get :index, params: { basket_id: basket }
    assert_response :success
    expect(assigns(:basket_items)).not_to be_nil
  end

  it "gets new" do
    get :new, params: { basket_id: basket }
    expect(response.status).to eq(200)
  end

  it "creates basket_item" do
    expect {
      post :create, params: { basket_id: basket, basket_item: { market_runner_id: runner2, weighting: 27 } }
    }.to change(BasketItem, :count).by(1)

    # assert_redirected_to basket_rule_basket_rule_items_path(basket_rules(:one), assigns(:basket_item))
  end

  it "shows basket_item" do
    get :show, params: { id: basket_item }
    assert_response :success
  end

  it "gets edit" do
    get :edit, params: { id: basket_item }
    assert_response :success
  end

  it "updates basket_item" do
    put :update, params: { id: basket_item,
                           basket_item: { market_runner_id: runner, weighting: 27 } }
    # assert_redirected_to basket_item_path(assigns(:basket_item))
  end

  it "destroys basket_item" do
    expect {
      delete :destroy, params: { id: basket_item }
    }.to change(BasketItem, :count).by(-1)

    # assert_redirected_to basket_items_path
  end
end

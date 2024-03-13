# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe MarketRunnersController, type: :controller do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }

  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:hometeam) { create(:team, sport: sport) }
  let(:awayteam) { create(:team, sport: sport) }
  let(:menu_path) { create(:menu_path, sport: sport) }
  let(:soccermatch) { create(:soccer_match, live_priced: true, division: division, hometeam: hometeam, awayteam: awayteam) }

  let(:bet_market) { create(:bet_market, match: soccermatch) }
  let!(:market_runner) { create(:market_runner, bet_market: bet_market) }

  it "should_get_index" do
    get :index, params: { bet_market_id: bet_market }
    assert_response :success
    expect(assigns(:market_runners)).not_to be_nil
  end

  it "should_get_new" do
    get :new, params: { bet_market_id: bet_market }
    assert_response :success
  end

  describe "create" do
    it "should_create_market_runner" do
      expect {
        post :create, params: {
          bet_market_id: bet_market,
          market_runner: {
            description: "No Goal",
            asianLineId: 0,
            selectionId: 1,
            sortorder: 0,
          },
        }
      }.to change(MarketRunner, :count).by(1)

      assert_redirected_to market_runner_path(assigns(:market_runner))
    end

    it "should_create_market_runner via json" do
      expect {
        post :create, params: {
          bet_market_id: bet_market,
          market_runner: {
            description: "No Goal",
            asianLineId: 0,
            selectionId: 1,
            sortorder: 0,
          },
        }, format: :json
        assert_response :success
      }.to change(MarketRunner, :count).by(1)
    end
  end

  it "should_show_market_runner" do
    get :show, params: { id: market_runner.id }
    assert_response :success
  end

  it "should_get_edit" do
    get :edit, params: { id: market_runner.id }
    assert_response :success
  end

  it "should_update_market_runner" do
    put :update, params: { id: market_runner.id, market_runner: { description: "runner" } }
    assert_redirected_to market_runner_path(assigns(:market_runner))
  end

  it "should_destroy_market_runner" do
    expect {
      delete :destroy, params: { id: market_runner.id }
    }.to change(MarketRunner, :count).by(-1)

    assert_redirected_to bet_market_market_runners_path(bet_market)
  end
end

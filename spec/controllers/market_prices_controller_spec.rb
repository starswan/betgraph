# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe MarketPricesController, type: :controller do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }

  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:hometeam) { create(:team, sport: sport) }
  let(:awayteam) { create(:team, sport: sport) }
  let(:menu_path) { create(:menu_path, sport: sport) }
  let!(:soccermatch) do
    create(:soccer_match, live_priced: true, division: division,
                          hometeam: hometeam, awayteam: awayteam)
  end

  let(:bet_market) { soccermatch.bet_markets.last }

  before do
    bm = create(:bet_market, match: soccermatch, name: market_type.name,
                             market_runners: build_list(:market_runner, 2))

    create(:market_price_time,
           market_prices: [build(:market_price, market_runner: bm.market_runners.first)])
  end

  let(:market_runner) { MarketRunner.last }
  let(:market_price_time) { MarketPriceTime.last }
  let(:market_price) { MarketPrice.last }

  it "gets new" do
    get :new, params: { market_runner_id: market_runner }
    assert_response :success
  end

  it "creates market price" do
    expect {
      post :create, params: { market_runner_id: market_runner,
                              market_price: { market_price_time_id: market_price_time,
                                              back1price: 34,
                                              back1amount: 17 } }
    }.to change(MarketPrice, :count).by(1)

    assert_redirected_to market_price_path(assigns(:market_price))
  end

  it "does not create market price on error" do
    expect {
      post :create, params: { market_runner_id: market_runner,
                              market_price: { market_price_time_id: market_price_time } }
    }.to change(MarketPrice, :count).by(0)
  end

  it "shows market price" do
    get :show, params: { id: market_price, market_runner_id: market_runner }
    assert_response :success
  end

  it "destroys market price" do
    expect {
      delete :destroy, params: { id: market_price, market_runner_id: market_runner.id }
    }.to change(MarketPrice, :count).by(-1)

    assert_response :redirect
    # assert_redirected_to market_prices_path
    # assert_redirected_to market_prices(:one).market_runner
    # assert_redirected_to market_runner_market_prices_path(market_runner)
  end
end

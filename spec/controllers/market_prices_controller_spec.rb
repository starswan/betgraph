#
# $Id$
#
require "rails_helper"

RSpec.describe MarketPricesController, type: :controller do
  let(:season) { create(:season) }
  let(:market_runner) { MarketRunner.last }
  let(:market_price) { Price.first }
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
  let(:market_price_time) { create(:market_price_time) }

  before do
    create(:bet_market, match: soccermatch, name: market_type.name,
                        market_runners: build_list(:market_runner, 2))

    # r = create(:market_runner, bet_market: bet_market)
    # create(:market_price_time,
    #        market_prices: [build(:market_price, market_runner: r)])
    create(:market_runner, bet_market: bet_market, prices: build_list(:price, 1, market_price_time: market_price_time))
  end

  it "gets new" do
    get :new, params: { market_runner_id: market_runner }
    assert_response :success
  end

  it "creates market price" do
    expect {
      post :create, params: { market_runner_id: market_runner.id,
                              market_price: { market_price_time_id: market_price_time.id,
                                              back_price: 34,
                                              back_amount: 17,
                                              depth: 1 } }
    }.to change(Price, :count).by(1)

    assert_redirected_to market_runner_path(market_runner)
  end

  it "does not create market price on error" do
    expect {
      post :create, params: { market_runner_id: market_runner,
                              market_price: { market_price_time_id: market_price_time } }
    }.to change(Price, :count).by(0)
  end

  # xit "shows market price" do
  #   get :show, params: { id: market_price.id, market_runner_id: market_runner }
  #   assert_response :success
  # end
  #
  # xit "destroys market price" do
  #   expect {
  #     delete :destroy, params: { id: market_price, market_runner_id: market_runner.id }
  #   }.to change(Price, :count).by(-1)
  #
  #   assert_response :redirect
  #   # assert_redirected_to market_prices_path
  #   # assert_redirected_to market_prices(:one).market_runner
  #   assert_redirected_to market_runner_market_prices_path(market_runner)
  # end
end

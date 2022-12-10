# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe TradesController, type: :controller do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }

  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:hometeam) { create(:team) }
  let(:awayteam) { create(:team) }
  let(:menu_path) { create(:menu_path, sport: sport) }
  let(:soccermatch) { create(:soccer_match, live_priced: true, division: division, hometeam: hometeam, awayteam: awayteam) }

  let(:bet_market) { create(:bet_market, match: soccermatch) }
  let!(:market_runner) { create(:market_runner, bet_market: bet_market) }
  let!(:trade) { create(:trade, market_runner: market_runner) }

  it "gets index" do
    get :index, params: { market_runner_id: market_runner }
    assert_response :success
    expect(assigns(:trades)).not_to be_nil
  end

  it "gets new" do
    get :new, params: { market_runner_id: market_runner }
    assert_response :success
  end

  context "with login" do
    let!(:login) { create(:login) }

    let(:hometeam) { create(:team) }
    let(:awayteam) { create(:team) }
    let(:menu_path) { create(:menu_path, sport: sport) }
    let(:soccermatch) { create(:soccer_match, live_priced: true, division: division, hometeam: hometeam, awayteam: awayteam) }
    let(:match_name) { "#{hometeam} vs #{awayteam}" }

    let(:bet_market) { create(:bet_market, match: soccermatch) }
    let(:market_runner) { create(:market_runner, bet_market: bet_market) }

    before do
      stub_betfair_login "Soccer", [build(:betfair_event, name: "Match", children: [build(:betfair_market, id: "1.#{bet_market.marketid}")])]

      stub_request(:post, "https://api.betfair.com/exchange/betting/rest/v1.0/listMarketBook/")
        .with(
          body: "{\"marketIds\":[\"1.#{bet_market.marketid}\"],\"priceProjection\":{\"priceData\":[\"EX_BEST_OFFERS\"],\"exBestOffersOverrides\":{\"bestPricesDepth\":3}}}",
        )
        .to_return(body: [{ marketId: "1.1",
                            betDelay: 5,
                            inplay: false,
                            complete: true }].to_json)
    end

    it "creates trade" do
      expect {
        post :create, params: { market_runner_id: market_runner, trade: { side: "B", size: 10, price: 5.5 } }
      }.to change(Trade, :count).by(1)

      # assert_redirected_to trade_path(assigns(:trade))
    end
  end

  it "shows trade" do
    get :show, params: { id: trade }
    assert_response :success
  end

  it "gets edit" do
    get :edit, params: { id: trade }
    assert_response :success
  end

  it "updates trade" do
    put :update, params: { id: trade, trade: { size: 4 } }
    # assert_redirected_to trade_path(assigns(:trade))
  end

  it "destroys trade" do
    expect {
      delete :destroy, params: { id: trade }
    }.to change(Trade, :count).by(-1)

    # assert_redirected_to trades_path
  end
end

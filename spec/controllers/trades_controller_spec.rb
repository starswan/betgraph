# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe TradesController, type: :controller do
  context "without login" do
    let(:soccermatch) { create(:soccer_match, live_priced: true, division: division) }
    let(:sport) { create(:soccer) }
    let(:calendar) { create(:calendar, sport: sport) }
    let(:season) { create(:season, calendar: calendar) }
    let(:division) { create(:division, calendar: calendar) }

    let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
    let(:hometeam) { create(:team) }
    let(:awayteam) { create(:team) }
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

  context "with login", :vcr, :betfair do
    before do
      create(:login)
      sport = create(:soccer, betfair_sports_id: 1, betfair_market_types: build_list(:betfair_market_type, 1, name: "Match Odds"))
      calendar = create(:calendar, sport: sport)
      division = create(:division, calendar: calendar)

      RefreshSportListJob.perform_now
      sport.competitions.find_by!(name: "English Championship").update!(active: true, division: division)
      MakeMatchesJob.perform_now(sport)
    end

    let(:market_runner) { MarketRunner.last }

    it "creates and performs a trade" do
      expect {
        post :create, params: { market_runner_id: market_runner, trade: { side: "L", size: 1, price: 3.6 } }
      }.to change(Trade, :count).by(1)
    end
  end
end

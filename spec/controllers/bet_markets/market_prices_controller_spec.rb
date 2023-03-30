# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

module BetMarkets
  RSpec.describe MarketPricesController, type: :controller do
    let(:season) { create(:season) }
    let(:sport) { season.calendar.sport }
    let(:market_price_time) { create(:market_price_time) }

    let(:soccermatch) do
      create(:soccer_match, live_priced: true,
                            division: create(:division, calendar: season.calendar),
                            hometeam: create(:team, sport: sport),
                            awayteam: create(:team, sport: sport))
    end
    let(:bet_market) do
      create(:bet_market, match: soccermatch,
                          market_runners: build_list(:market_runner, 1,
                                                     market_prices: build_list(:market_price, 1, market_price_time: market_price_time)))
    end

    describe "#index" do
      it "gets the prices" do
        get :index, params: { bet_market_id: bet_market }

        expect(response.status).to eq(200)
        expect(assigns(:market_prices).map(&:market_runner_id)).to eq([bet_market.market_runners.first.id])
      end
    end
  end
end

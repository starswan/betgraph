# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe SoccerMatches::BasketsController, type: :controller do
  let(:season) { create(:season) }
  let(:match) { SoccerMatch.last }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }

  before do
    sm = create(:soccer_match, division: division, baskets: build_list(:basket, 1))
    mpt = create(:market_price_time, time: sm.kickofftime + 1.minute)
    bm = create(:bet_market, match: sm)
    runners = create_list(:market_runner, 4, bet_market: bm)
    runners.each { |r| create(:market_price, market_runner: r, market_price_time: mpt) }
    create(:basket_item, basket: sm.baskets.first, market_runner: bm.market_runners.first)
    create_list(:basket_item, 1, basket: sm.baskets.first, market_runner: bm.market_runners.second)
    create_list(:basket_item, 1, basket: sm.baskets.first, market_runner: bm.market_runners.third)
    create_list(:basket_item, 1, basket: sm.baskets.first, market_runner: bm.market_runners.fourth)
    match.reload
  end

  it "has baskets" do
    expect(match.baskets.count).to eq(1)
  end

  it "has active baskets" do
    expect(match.baskets.select(&:complete?)).to eq(match.baskets)
  end

  describe "GET #index" do
    render_views

    it "returns http success" do
      get :index, params: { soccer_match_id: match }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #destroy" do
    let(:basket) { match.baskets.first }

    it "returns redirects" do
      delete :destroy, params: { soccer_match_id: match, id: basket }
      expect(response).to redirect_to match_baskets_path(match)
    end
  end
end

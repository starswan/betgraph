# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe InferGoalTimesJob, type: :job do
  let(:season) { create(:season) }
  let!(:price_time) { create :market_price_time }
    # market_prices: [
    #   build(:market_price, market_runner: market.market_runners.first),
    #   build(:market_price, market_runner: market.market_runners.second),
    # ])
  let!(:soccermatch) do
    create(:soccer_match,
           division: division,
           bet_markets: [
             build(:bet_market,
                   name: "Correct Score",
                   market_runners: [
                     build(:market_runner, prices: build_list(:price, 1, market_price_time: price_time)),
                     build(:market_runner, prices: build_list(:price, 1, market_price_time: price_time)),
                   ]),
           ])
  end
  let!(:result) { create(:result, match: soccermatch) }
  let(:market) { soccermatch.bet_markets.first }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }

  before do
    sport = Sport.find_by(name: "soccer")
    if sport
      create(:betfair_market_type, sport: sport, name: "Correct Score")
    else
      create(:sport, name: "soccer",
                     betfair_market_types: [
                       build(:betfair_market_type, name: "Correct Score"),
                     ])
    end
  end

  it "peforms" do
    described_class.perform_later soccermatch
  end
end

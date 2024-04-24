# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe InferGoalTimesJob, type: :job do
  let(:sport) { create(:soccer, calendars: build_list(:calendar, 1)) }
  let(:season) { create(:season, calendar: sport.calendars.first) }
  let(:soccermatch) do
    create(:soccer_match,
           division: division,
           result: build(:result),
           bet_markets: [
             build(:bet_market,
                   name: "Correct Score",
                   market_runners: [
                     build(:market_runner),
                     build(:market_runner),
                   ]),
           ])
  end
  let(:market) { soccermatch.bet_markets.first }
  let!(:price_time) do
    create(:market_price_time,
           market_prices: [
             build(:market_price, market_runner: market.market_runners.first),
             build(:market_price, market_runner: market.market_runners.second),
           ])
  end
  let(:division) { create(:division, calendar: season.calendar) }

  before do
    create(:betfair_market_type, sport: sport, name: "Correct Score")
  end

  it "peforms" do
    described_class.perform_later soccermatch
  end
end

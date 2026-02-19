# frozen_string_literal: true

require "rails_helper"

RSpec.describe InferAllGoalTimesJob, type: :job do
  let(:sport) { create(:soccer, calendars: build_list(:calendar, 1)) }
  let(:season) { create(:season, calendar: sport.calendars.first) }
  let!(:price_time) { create :market_price_time }
  let!(:soccer_match) do
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
  let(:market) { soccer_match.bet_markets.first }
  let(:division) { create(:division, calendar: season.calendar) }

  before do
    create(:betfair_market_type, sport: sport, name: "Correct Score")
  end

  it "performs" do
    described_class.perform_later
    expect(soccer_match.scorers).to eq([])
  end
end

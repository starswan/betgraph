# frozen_string_literal: true

require "rails_helper"

RSpec.describe InferAllGoalTimesJob, type: :job do
  let(:season) { create(:season) }
  let!(:price_time) { create :market_price_time }
    # market_prices: [
    #   build(:market_price, market_runner: market.market_runners.first),
    #   build(:market_price, market_runner: market.market_runners.second),
    # ])
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
  let(:sport) { season.calendar.sport }

  before do
    sport = Sport.find_by(name: "Soccer")
    if sport
      create(:betfair_market_type, sport: sport, name: "Correct Score")
    else
      create(:sport, name: "Soccer",
                     betfair_market_types: [
                       build(:betfair_market_type, name: "Correct Score"),
                     ])
    end
  end

  it "performs" do
    described_class.perform_later
    expect(soccer_match.scorers).to eq([])
  end
end

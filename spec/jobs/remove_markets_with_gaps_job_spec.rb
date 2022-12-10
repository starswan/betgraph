# frozen_string_literal: true

require "rails_helper"

RSpec.describe RemoveMarketsWithGapsJob, type: :job do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }
  let(:now) { Time.zone.now }

  before do
    # make it asian so there is no validation of overrounds
    sm = create(:soccer_match, division: division, kickofftime: now, name: "A v B", bet_markets: build_list(:bet_market, 1, :closed, :asian, market_runners: build_list(:market_runner, 1)))
    runner = sm.bet_markets.first.market_runners.first
    # bm = sm.bet_markets.first
    create(:market_price_time, time: now, market_prices: build_list(:market_price, 1, market_runner: runner))
    create(:market_price_time, time: now + 10.minutes, market_prices: build_list(:market_price, 1, market_runner: runner))
  end

  it "removes the market" do
    expect { described_class.perform_now }.to change(BetMarket, :count).by(-1)
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe RemoveAllMarketsWithGapsJob, type: :job do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:now) { Time.zone.now }
  let(:mpt_now) { create(:market_price_time, time: now) }
  let(:mpt_later) { create(:market_price_time, time: now + 10.minutes) }

  before do
    # make it asian so there is no validation of overrounds
    create(:soccer_match, division: division, kickofftime: now, name: "A v B",
                          bet_markets: build_list(:bet_market, 1, :closed, :asian,
                                                  market_runners: [
                                                    build(:market_runner, prices: [
                                                      build(:price, market_price_time: mpt_now, created_at: mpt_now.time),
                                                      build(:price, market_price_time: mpt_later, created_at: mpt_later.time),
                                                    ]),
                                                  ]))
  end

  it "removes the market" do
    expect {
      described_class.perform_now
    }.to change(BetMarket, :count).by(-1)
  end
end

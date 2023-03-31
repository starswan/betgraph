# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"
require "webmock/rspec"

RSpec.describe ExecuteTradeJob, :betfair, type: :job do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }
  let(:match) { create(:soccer_match, division: division) }
  let!(:market) { create(:bet_market, match: match, market_runners: [build(:market_runner)]) }
  let(:runner) { market.market_runners.first }
  let(:trade) { create(:trade, market_runner: runner) }

  before do
    create(:login)

    stub_betfair_login "Soccer", [build(:betfair_event, name: "Match", children: [build(:betfair_market, id: "1.#{market.marketid}")])]

    stub_request(:post, "https://api.betfair.com/exchange/betting/rest/v1.0/listMarketBook/")
        .with(
          body: { "marketIds" => ["1.#{market.marketid}"],
                  "priceProjection" => { "priceData" => %w[EX_BEST_OFFERS],
                                         "exBestOffersOverrides" => { "bestPricesDepth" => 3 } } }.to_json,
        )
        .to_return(
          headers: { "Content-Type" => "application/json" },
          body: [{ marketId: "1.1",
                   betDelay: 5,
                   inplay: false,
                   runners: [
                     {
                       selectionId: runner.selectionId,
                       asianLineId: runner.asianLineId,
                       back: {},
                     },
                   ],
                   complete: true }].to_json,
        )
  end

  it "performs" do
    described_class.perform_later trade
  end
end

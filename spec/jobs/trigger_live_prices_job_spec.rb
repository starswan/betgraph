# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe TriggerLivePricesJob, :betfair, type: :job do
  let(:sport) do
    create(:sport, name: "Soccer",
                   betfair_market_types: [
                     build(:betfair_market_type, name: "Correct Score"),
                   ])
  end
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }
  let(:match) do
    create(:soccer_match,
           division: division,
           live_priced: true,
           bet_markets: [
             build(:bet_market,
                   live: true,
                   active: true,
                   markettype: "Correct Score",
                   name: "Correct Score",
                   market_runners: [
                     build(:market_runner),
                     build(:market_runner),
                   ]),
           ])
  end
  let(:market) { match.bet_markets.first }
  let(:runner) { market.market_runners.first }

  before do
    create(:season, calendar: calendar)
    create(:login)

    stub_betfair_login "Soccer", [build(:betfair_event, name: "A Match", children: [build(:betfair_market, id: "1.#{market.marketid}")])]

    stub_request(:post, "https://api.betfair.com/exchange/betting/rest/v1.0/listMarketBook/")
        .with(
          body: { "marketIds" => ["1.#{market.marketid}"],
                  "priceProjection" => { "priceData" => %w[EX_BEST_OFFERS],
                                         "exBestOffersOverrides" => { "bestPricesDepth" => 3 } } }.to_json,
        )
        .to_return(headers: { "Content-Type" => "application/json" },
                   body: [{ marketId: "1.#{market.marketid}",
                            betDelay: 5,
                            inplay: false,
                            status: "ACTIVE",
                            runners: [
                              {
                                selectionId: runner.selectionId,
                                asianLineId: runner.asianLineId,
                                handicap: 0,
                                ex: { availableToBack: [{}], availableToLay: [] },
                                status: "ACTIVE",
                              },
                            ],
                            complete: true }].to_json)
  end

  it "doesn't crash" do
    subject.perform
  end
end

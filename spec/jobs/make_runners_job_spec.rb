# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe MakeRunnersJob, :betfair, type: :job do
  let(:hometeam) { create(:team) }
  let(:awayteam) { create(:team) }
  let(:division) { create(:division) }
  let(:match) do
    create(:soccer_match, division: division, venue_id: hometeam.id, teams: [hometeam, awayteam],
                          bet_markets: [build(:bet_market, marketid: 234)])
  end

  before do
    create(:season, calendar: division.calendar)
    create(:login)
    stub_betfair_login

    stub_request(:post, "https://api.betfair.com/exchange/betting/rest/v1.0/listMarketCatalogue/")
      .with(
        body: { maxResults: "1", filter: { marketIds: ["1.234"] }, marketProjection: %w[MARKET_DESCRIPTION MARKET_START_TIME EVENT RUNNER_DESCRIPTION] }.to_json,
      )
      .to_return(
        headers: { "Content-Type" => "application/json" },
        body: [].to_json,
      )

    stub_request(:post, "https://api.betfair.com/exchange/betting/rest/v1.0/listMarketBook/")
      .with(
        body: { marketIds: ["1.234"], marketProjection: %w[MARKET_DESCRIPTION MARKET_START_TIME EVENT RUNNER_DESCRIPTION] }.to_json,
      )
      .to_return(
        headers: { "Content-Type" => "application/json" },
        body: [{ marketId: "1.1",
                 betDelay: 5,
                 inplay: false,
                 complete: true }].to_json,
      )
    stub_request(:put, "http://webservice.local/matches/#{match.id}/bet_markets/#{match.bet_markets.first.id}.json")
      .with(
        body: { bet_market: { runners_may_be_added: false, live_priced: false, live: false } }.to_json,
      )
      .to_return(body: "")
  end

  it "performs" do
    described_class.perform_later match.bet_markets.first
  end
end

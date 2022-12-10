# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe MakeMatchesJob, :betfair, type: :job do
  before do
    create(:login)
    sport = create(:soccer, basket_rules: [build(:basket_rule, name: "Rule 1")])
    calendar = create(:calendar, sport: sport)
    create(:season, calendar: calendar)
    division = create(:division, calendar: calendar)
    create(:team, sport: sport, name: hometeam_name)
    create(:team, sport: sport, name: awayteam_name)
    create(:menu_path, division: division, parent: sport.menu_paths.first, name: ["Soccer", match_name])
    stub_betfair_login "Soccer", [build(:betfair_event, name: match_name, children: [build(:betfair_market)])]
  end

  Market = Struct.new :menuPath, :marketTime, :exchangeId, :marketId, :name,
                      :marketType, :marketStatus, :turningInPlay,
                      :numberOfWinners, :numberOfRunners, :totalMatchedAmount
  # let(:sport) { create(:sport, name: 'Soccer', basket_rules: [build(:basket_rule, name: 'Rule 1')]) }
  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:hometeam_name) { "HomeTeam" }
  let(:awayteam_name) { "AwayTeam" }
  let(:match_name) { "#{hometeam_name} v #{awayteam_name}" }

  context "soccer match" do
    let(:menu_path) { MenuPath.last }
    let(:division) { Division.last }
    let(:sport) { division.sport }
    let(:soccermatch) do
      create(:soccer_match, live_priced: false, division: division, name: match_name)
    end
    let(:new_market) { create(:bet_market, match: soccermatch) }

    before do
      match_params =  {
        soccer_match: {
          kickofftime: "2020-09-13T20:25:00.000+00:00",
          name: "HomeTeam v AwayTeam",
        },
      }
      stub_request(:post, "http://webservice.local/divisions/#{soccermatch.division.id}/soccer_matches.json")
          .with(body: match_params)
          .to_return(body: { id: soccermatch.id }.to_json)

      market_params = {
        bet_market: {
          marketid: 170406085,
          name: "Moneyline",
          markettype: "MATCH_ODDS",
          status: "ACTIVE",
          live: false,
          runners_may_be_added: false,
          time: "2020-09-13T20:25:00.000+00:00",
          exchange_id: 1,
          number_of_winners: 1,
          number_of_runners: 0,
          total_matched_amount: 0,
        },
      }
      stub_request(:post, "http://webservice.local/matches/#{soccermatch.id}/bet_markets.json")
          .with(body: market_params.to_json)
          .to_return(body: { id: new_market.id, active: true }.to_json)
    end

    it "makes a soccer match" do
      subject.perform sport
    end
  end

  xcontext "making matches" do
    let(:new_market) { create(:bet_market, match: match) }
    let(:menu_path) { MenuPath.last }

    it "makes matches" do
      stub_request(:post, "http://webservice.local/divisions/988399130/american_football_matches.json")
        .with(
          body: {
            american_football_match: {
              kickofftime: "2019-03-05T15:00:00.000+00:00",
              name: "Boston @ Chicago",
            },
          }.to_json,
        ).to_return(body: { id: match.id }.to_json)

      stub_request(:post, "http://webservice.local/matches/#{match.id}/bet_markets.json")
        .with(
          body: {
            bet_market: {
              marketid: 25,
              name: "MarketName2",
              markettype: "Type",
              status: "ACTIVE",
              live: false,
              runners_may_be_added: false,
              time: "2019-03-05T15:00:00.000+00:00",
              exchange_id: 1,
              number_of_winners: 1,
              number_of_runners: 3,
              total_matched_amount: 0.01,
            },
          }.to_json,
        )
        .to_return(body: { id: new_market.id, active: true }.to_json)

      # market = Market.new menu_paths(:burnleyMillwall).name, Time.now, 1, 24, 'MarketName1',
      #                     'Type', 'ACTIVE', true, 1, 3, 0.01
      bostonChicago = Market.new menu_path.name, Time.new(2019, 3, 5, 15), 1, 25, "MarketName2",
                                 "Type", "ACTIVE", true, 1, 3, 0.01
      # f1race = Market.new menu_paths(:f1race).name, Time.now, 1, 26, 'MarketName3',
      #                     'Type', 'ACTIVE', true, 1, 3, 0.01
      count = 0
      subject.make_matches sport, [bostonChicago] do |_db_bet_market|
        count = count + 1
      end
      # expect(client.matchCount).to eq(1)
      # expect(count).to eq(1)
    end
  end
end

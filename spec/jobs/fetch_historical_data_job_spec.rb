#
# $Id$
#
require "rails_helper"

RSpec.describe FetchHistoricalDataJob, :vcr, type: :job do
  let(:soccer) do
    create :soccer, calendars: build_list(:calendar, 1),
                    betfair_market_types: [build(:betfair_market_type, :match_odds),
                                           build(:betfair_market_type, :correct_score)]
  end
  let(:division) do
    create(:division, calendar: soccer.calendars.first,
                      football_division: build(:football_division, rapid_api_country: "England", rapid_api_name: "League One"))
  end
  let(:soccer_match) do
    create(:soccer_match, kickofftime: Time.zone.local(2016, 11, 1, 19, 45, 0),
                          division: division,
                          name: "Luton v Bristol City")
  end

  before do
    create(:bet_market, :match_odds, match: soccer_match)
  end

  context "with league one" do
    before do
      # pick up both match_odds and correct score markets
      create(:bet_market, :correct_score, match: soccer_match)

      create(:team_name, name: "Fulham", team: build(:team, sport: soccer))
      create(:team_name, name: "Leeds", team: build(:team, sport: soccer))
      create(:team_name, name: "Bolton", team: build(:team, sport: soccer))
      create(:team_name, name: "Birmingham", team: build(:team, sport: soccer))
    end

    context "when first of november 2017" do
      let(:kickofftime) { Time.zone.local(2017, 11, 1, 19, 45, 0) }

      before do
        create(:soccer_match, kickofftime: kickofftime,
                              division: division,
                              result: build(:result, homescore: 4, awayscore: 2),
                              name: "Preston v Aston Villa",
                              bet_markets: [build(:bet_market, :match_odds, exchange_id: 1, marketid: 136_090_297)])
      end

      it "creates prices" do
        expect {
          expect {
            described_class.perform_now kickofftime.to_date, "GB"
          }.to change(BetMarket, :count).by(1)
        }.to change(MarketPrice, :count).by(20)
      end
    end

    context "when third april 2018" do
      let(:kickofftime) { Time.zone.local(2018, 4, 3, 19, 45, 0) }

      before do
        create(:soccer_match, kickofftime: kickofftime,
                              division: division,
                              result: build(:result, homescore: 1, awayscore: 2),
                              name: "Aston Villa v Reading")
      end

      it "creates prices" do
        expect {
          expect {
            described_class.perform_now kickofftime.to_date, "GB"
          }.to change(BetMarket, :count).by(2)
        }.to change(MarketPrice, :count).by(1319)
      end
    end
  end

  context "with man city vs liverpool" do
    before do
      create(:soccer_match, kickofftime: Time.zone.local(2017, 9, 9, 12, 30, 0),
                            division: division,
                            name: "Man City v Liverpool")
    end

    it "doesnt create prices for ninth of sep" do
      expect {
        expect {
          described_class.perform_now Date.new(2017, 9, 9), "GB"
        }.to change(BetMarket, :count).by(0)
      }.to change(MarketPrice, :count).by(0)
    end
  end
end

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
    create(:soccer_match, kickofftime: Time.zone.local(2020, 2, 12, 12, 29, 0),
                          division: division,
                          result: build(:result, homescore: 3, awayscore: 0),
                          name: "MK Dons v Cheltenham")
  end

  before do
    # pick up both match_odds and correct score markets
    create(:bet_market, :match_odds, match: soccer_match)
    create(:bet_market, :correct_score, match: soccer_match)

    create(:soccer_match, kickofftime: Time.zone.local(2017, 11, 1, 19, 45, 0),
                          division: division,
                          result: build(:result, homescore: 4, awayscore: 2),
                          name: "Preston v Aston Villa")

    create(:soccer_match, kickofftime: Time.zone.local(2018, 4, 3, 19, 45, 0),
                          division: division,
                          result: build(:result, homescore: 1, awayscore: 2),
                          name: "Aston Villa v Reading")

    create(:team_name, name: "Fulham", team: build(:team, sport: soccer))
    create(:team_name, name: "Leeds", team: build(:team, sport: soccer))
    create(:team_name, name: "Bolton", team: build(:team, sport: soccer))
    create(:team_name, name: "Birmingham", team: build(:team, sport: soccer))
  end

  it "creates prices for first of november" do
    expect {
      expect {
        described_class.perform_now Date.new(2017, 11, 1), "GB"
      }.to change(BetMarket, :count).by(2)
    }.to change(MarketPrice, :count).by(20)
  end

  it "creates prices for third of april" do
    expect {
      expect {
        described_class.perform_now Date.new(2018, 4, 3), "GB"
      }.to change(BetMarket, :count).by(2)
    }.to change(MarketPrice, :count).by(1318)
  end
end

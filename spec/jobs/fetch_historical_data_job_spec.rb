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
    create(:soccer_match, kickofftime: Time.zone.local(2020, 2, 12, 12, 30, 0),
                          division: division,
                          result: build(:result, homescore: 3, awayscore: 0),
                          name: "Milton Keynes Dons v Cheltenham")
  end

  before do
    create(:login)
    # pick up both match_odds and correct score markets
    create(:bet_market, :match_odds, match: soccer_match)
    create(:bet_market, :correct_score, match: soccer_match)

    create(:soccer_match, kickofftime: Time.zone.local(2017, 11, 1, 19, 45, 0),
                          division: division,
                          result: build(:result, homescore: 4, awayscore: 2),
                          name: "Preston v Aston Villa")
  end

  it "creates markets and prices" do
    expect {
      expect {
        described_class.perform_now Date.new(2017, 11, 1), "GB"
      }.to change(BetMarket, :count).by(2)
    }.to change(MarketPrice, :count).by(20)
  end
end

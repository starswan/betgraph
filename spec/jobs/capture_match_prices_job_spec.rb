# frozen_string_literal: true

require "rails_helper"

RSpec.describe CaptureMatchPricesJob, :vcr, :betfair, type: :job do
  let!(:sport) do
    create(:sport, name: "Soccer",
                   betfair_sports_id: 1,
                   betfair_market_types: [
                     build(:betfair_market_type, name: "Correct Score"),
                   ])
  end
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }
  let(:soccer_match) { SoccerMatch.find_by! name: "Hibernian v Hearts" }

  before do
    create(:season, calendar: calendar)
    create(:login)
    RefreshSportListJob.perform_now
    sport.competitions.find_by!(name: "Scottish Premiership").update!(active: true, division: division)

    # make a few matches - but only really want one of them...
    MakeMatchesJob.perform_now(sport)

    BetMarket.all.update_all(active: true, live: true)
    SoccerMatch.update_all(live_priced: true)
    soccer_match.bet_markets.first.update!(status: "OPEN")
  end

  it "creates market prices" do
    expect {
      described_class.perform_now soccer_match
    }.to change(MarketPrice, :count).by(19)
  end
end

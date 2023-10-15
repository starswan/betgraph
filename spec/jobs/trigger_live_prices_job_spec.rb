# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe TriggerLivePricesJob, :vcr, :betfair, type: :job do
  let!(:sport) do
    create(:sport, name: "Soccer",
                   betfair_sports_id: 1,
                   betfair_market_types: [
                     build(:betfair_market_type, name: "Correct Score"),
                   ])
  end
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }

  before do
    create(:season, calendar: calendar)
    RefreshSportListJob.perform_now
    sport.competitions.find_by!(name: "English FA Cup").update!(active: true, division: division)

    # make a few matches - but only really want one of them...
    MakeMatchesJob.perform_now(sport)

    BetMarket.all.update_all(active: true, live: true)
    SoccerMatch.update_all(live_priced: true, kickofftime: Time.zone.now - 30.minutes)
  end

  it "extracts market prices" do
    expect {
      described_class.perform_now
    }.to change(MarketPrice, :count).by(38)
  end
end

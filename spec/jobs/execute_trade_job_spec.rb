# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe ExecuteTradeJob, :vcr, :betfair, type: :job do
  before do
    create(:login)
    sport = create(:soccer, betfair_sports_id: 1, betfair_market_types: build_list(:betfair_market_type, 1, name: "Match Odds"))
    calendar = create(:calendar, sport: sport)
    division = create(:division, calendar: calendar)

    RefreshSportListJob.perform_now
    sport.competitions.find_by!(name: "English Championship").update!(active: true, division: division)
    MakeMatchesJob.perform_now(sport)
  end

  let(:runner) { MarketRunner.last }
  let(:trade) { create(:trade, market_runner: runner, side: "B", size: 1, price: 3.5) }

  it "performs" do
    described_class.perform_later trade
  end
end

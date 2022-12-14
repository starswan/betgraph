# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe RefreshSportListJob, :vcr, :betfair, type: :job do
  before do
    create(:login)
    create(:soccer,
           betfair_sports_id: 1,
           betfair_market_types: [
             build(:betfair_market_type, name: "Match Odds"),
             build(:betfair_market_type, name: "Asian Handicap"),
           ],
           calendars: build_list(:calendar, 1, divisions: build_list(:division, 1)))
  end

  it "performs" do
    expect {
      described_class.perform_later
    }.to change(Competition, :count).by(169)
  end
end

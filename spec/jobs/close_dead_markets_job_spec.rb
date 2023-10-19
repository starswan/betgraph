# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe CloseDeadMarketsJob, type: :job do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }
  let(:soccermatch) { create(:soccer_match, division: division, kickofftime: Time.zone.now - 90.minutes, endtime: Time.zone.now - 30.minutes) }
  let(:soccermatch2) { create(:soccer_match, division: division, kickofftime: Time.zone.now + 30.minutes, endtime: Time.zone.now + 30.minutes) }

  before do
    create(:bet_market, :overunder, match: soccermatch, time: soccermatch.kickofftime)
    create(:bet_market, match: soccermatch2, time: soccermatch2.kickofftime)

    described_class.perform_later
  end

  it "closes markets past the match end date" do
    expect(BetMarket.not_closed.count).to eq(1)
  end
end

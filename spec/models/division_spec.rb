# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Division do
  before do
    create(:season, :first, calendar: division.calendar)
  end

  let(:division) { create(:division) }
  let(:ko) { Time.zone.local(2011, 9, 16, 15, 0, 0) }
  let(:date) { Date.new(2011, 9, 16) }
  let!(:match) do
    create(:soccer_match,
           division: division,
           kickofftime: ko)
  end
  let(:hometeam) { match.hometeam }
  let(:awayteam) { match.awayteam }

  it "can find matches" do
    expect(division.find_match(hometeam, awayteam, date)).to eq(match)
  end
end

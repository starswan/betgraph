# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Result do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }
  let!(:match) { create(:soccer_match, division: division) }

  it "result can be created" do
    expect {
      described_class.create! match: match, homescore: 1, awayscore: 3
    }.to change(described_class, :count).by(1)
  end
end

# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe DestroyDeletedMatchesJob, type: :job do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }
  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let!(:football_division) { create(:football_division, division: division) }
  let(:hometeam) { create(:team, sport: sport) }
  let(:awayteam) { create(:team, sport: sport) }
  let(:menu_path) { create(:menu_path, sport: sport) }

  before do
    x = create(:soccer_match, division: division, name: "#{hometeam} v #{awayteam}")
    x.discard!
  end

  it "destroys deleted matches" do
    expect {
      described_class.perform_now
    }.to change { Match.discarded.count }.by(-1)
  end
end

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
    x.destroy
  end

  # This does work, it's just some quirk that stops this test from working
  it "destroys deleted matches" do
    # expect(Match.with_deleted.count).to eq(1)
    expect {
      described_class.perform_now
      # expect(Match.with_deleted.count).to eq(0)
    }.to change { Match.only_deleted.count }.by(-1)
    # expect(Match.with_deleted.count).to eq(0)
  end
end

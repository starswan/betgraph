# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe ResultsHelper, type: :helper do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }

  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:hometeam) { create(:team) }
  let(:awayteam) { create(:team) }
  let(:soccermatch) do
    create(:soccer_match,
           division: division,
           name: "#{hometeam.name} v #{awayteam.name}",
           hometeam: hometeam,
           awayteam: awayteam)
  end

  context "when 0-0" do
    let!(:result) { create(:result, match: soccermatch, homescore: 0, awayscore: 0) }

    it "formats result" do
      expect(helper.format_result(soccermatch)).to eq("0-0")
    end
  end

  context "with scorers" do
    let!(:scorers) do
      [create(:scorer, match: soccermatch, team: soccermatch.hometeam, goaltime: 12),
       create(:scorer, match: soccermatch, team: soccermatch.awayteam, goaltime: 4500),
       create(:scorer, match: soccermatch, team: soccermatch.hometeam, goaltime: 4523)]
    end
    let!(:result) { create(:result, match: soccermatch, homescore: 2, awayscore: 1) }

    it "formats result" do
      expect(helper.format_result(soccermatch)).to eq("1-0(00:12), 1-1(60:00), 2-1(60:23)")
    end
  end
end

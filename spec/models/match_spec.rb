# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Match do
  before do
    create(:season, calendar: calendar)
  end

  let(:sport) { create(:sport) }
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }
  let!(:hometeam) { create(:team, sport: sport) }
  let!(:awayteam) { create(:team, sport: sport) }
  let(:soccer_match) do
    create(:soccer_match,
           live_priced: true,
           division: division,
           bet_markets: build_list(:bet_market, 1,
                                   market_runners: build_list(:market_runner, 2)),
           name: "#{hometeam.name} v #{awayteam.name}").tap do |m|
      m.update!(scorers: [
        build(:scorer, team: hometeam, goaltime: 6),
        build(:scorer, team: hometeam, goaltime: 8),
      ])
    end
  end

  describe "#hometeam" do
    it "has home and away teams" do
      expect(soccer_match.hometeam).to eq(hometeam)
      expect(soccer_match.awayteam).to eq(awayteam)
    end
  end

  describe "#hometeam=" do
    let(:teamless_match) { build(:soccer_match) }

    it "can assign home and away teams" do
      teamless_match.hometeam = hometeam
      teamless_match.awayteam = awayteam
    end
  end

  describe "#activelive" do
    before do
      soccer_match
    end

    it "includes soccer match" do
      expect(described_class.activelive).to eq([soccer_match])
    end

    it "has a count" do
      expect(described_class.activelive.count).to eq(1)
    end
  end

  describe "homegoals" do
    it "gives goals after N minutes" do
      expect(soccer_match.homegoals(10)).to eq(2)
    end
  end

  describe "awaygoals" do
    it "gives goals after N minutes" do
      expect(soccer_match.awaygoals(10)).to eq(0)
    end
  end

  describe "homescorercount" do
    it "gives count of home team scorers" do
      expect(soccer_match.homescorercount).to eq(2)
    end
  end

  describe "awayscorercount" do
    it "gives count of away team scorers" do
      expect(soccer_match.awayscorercount).to eq(0)
    end
  end
end

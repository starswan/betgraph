# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Sport do
  let(:sport) do
    create(
      :sport,
      name: "Football",
      teams: [build(:team)],
    )
  end

  let(:calendar) { create(:calendar, sport: sport) }

  let(:division) { create(:division, calendar: calendar) }
  let(:division2) { create(:division, calendar: calendar) }
  let(:match1) { create(:soccer_match, division: division) }
  let(:match2) { create(:soccer_match, division: division2) }

  before do
    create(:season, calendar: calendar)
  end

  it "has some matches" do
    expect(sport.matches).to match_array([match1, match2])
  end

  it "motor sport match type is motor race" do
    motor_sport = described_class.create! name: "Motor Sport", betfair_sports_id: 800
    expect(motor_sport.match_type).to eq("MotorRace")
  end

  it "hockey match type is HockeyMatch" do
    tennis = described_class.create! name: "Hockey", betfair_sports_id: 37
    expect(tennis.match_type).to eq("HockeyMatch")
  end

  it "findTeam will return existing team" do
    expect(sport.findTeam(sport.teams.first.name)).to eq(sport.teams.first)
  end

  it "findTeam will create new team" do
    expect {
      expect {
        expect(sport.findTeam("Twenty").teamname).to eq("Twenty")
      }.to change(TeamName, :count).by(1)
    }.to change(Team, :count).by(1)
  end
end

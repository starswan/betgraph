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
      menu_paths: [
        build(:menu_path, name: ["Football", "Spanish Soccer"]),
        build(:menu_path, name: ["Football", "Interesting Things"]),
      ],
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
    assert_equal("MotorRace", motor_sport.match_type)
  end

  it "hockey match type is HockeyMatch" do
    tennis = described_class.create! name: "Hockey", betfair_sports_id: 37
    assert_equal("HockeyMatch", tennis.match_type)
  end

  it "top menu paths returns top menu paths" do
    assert_equal([["Football", "Spanish Soccer"], ["Football", "Interesting Things"], %w[Football]],
                 sport.top_menu_paths.collect(&:name))
  end

  it "findTeam will return existing team" do
    assert_equal(sport.teams.first, sport.findTeam(sport.teams.first.name))
  end

  it "findTeam will create new team" do
    expect {
      expect {
        assert_equal("Twenty", sport.findTeam("Twenty").teamname)
      }.to change(TeamName, :count).by(1)
    }.to change(Team, :count).by(1)
  end

private

  def assert_equal(a, b)
    expect(b).to eq(a)
  end
end

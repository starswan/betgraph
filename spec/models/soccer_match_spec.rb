# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe SoccerMatch do
  let!(:season) { create(:season, startdate: Date.new(2019, 8, 1)) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:division2) { create(:division, calendar: season.calendar) }
  let!(:match1) do
    create(:soccer_match,
           division: division,
           name: "One v Two",
           kickofftime: Date.new(2020, 1, 1),
           bet_markets: [
             build(:bet_market,
                   name: "Correct Score",
                   market_runners: [
                     build(:market_runner),
                   ]),
           ])
  end

  before do
    create(:season, calendar: season.calendar, startdate: Date.new(2020, 8, 1))
  end

  describe "#create" do
    before do
      create(:soccer_match, division: division2,
                            name: "One v Two",
                            kickofftime: Date.new(2020, 1, 2))
    end

    it "creates the teams involved" do
      expect(Team.all.map(&:name)).to match_array(%w[One Two])
    end
  end

  # Scotland violates this rule in an extreme way - so the code doesn't run for Scottish 6
  context "avoiding duplicate matches" do
    # maybe there is a simpler version of this - at least not allowing 2 identical matches
    # on the same day?
    it "prevents 2 identical matches in the same division and season" do
      expect(build(:soccer_match, division: division,
                                  name: "One v Two",
                                  kickofftime: Date.new(2020, 1, 2))).not_to be_valid
    end

    it "allows matches in different divisions" do
      expect(build(:soccer_match, division: division2,
                                  name: "One v Two",
                                  # football_season_id: season2.id,
                                  kickofftime: Date.new(2020, 1, 2))).to be_valid
    end

    it "allows matches in different seasons" do
      expect(build(:soccer_match, division: division,
                                  name: "One v Two",
                                  # football_season_id: season2.id,
                                  kickofftime: Date.new(2021, 1, 2))).to be_valid
    end
  end

  it "can estimate a result" do
    expect(match1.estimated_score).to eq([0, 0])
  end

  it "creating a soccer match creates a football match in the correct season" do
    expect {
      expect {
        expect {
          m = division.matches.create! name: "Three v Four", type: "SoccerMatch",
                                       kickofftime: Date.new(2020, 1, 1)
          expect(m.hometeam).not_to be_nil
          expect(m.awayteam).not_to be_nil
        }.to change(MatchTeam, :count).by(2)
      }.to change(described_class, :count).by(1)
    }.to change { season.matches.count }.by(1)
  end

  context "scorers" do
    let!(:s1) { create(:scorer, match: match1, team: match1.hometeam, goaltime: 60) }
    let!(:s2) { create(:scorer, match: match1, team: match1.hometeam, goaltime: 120) }
    # goaltimes allow 15 minutes for half-time after 45 minutes
    let!(:s3) { create(:scorer, match: match1, team: match1.awayteam, goaltime: 50.minutes) }
    let(:smatch) { match1.reload }

    before do
      create(:result, match: match1, homescore: 1, awayscore: 2)
    end

    it "has scorers" do
      expect(smatch.homescorers).to match_array [s1, s2]
      expect(smatch.awayscorers).to eq([s3])
    end

    it "has scores" do
      expect(match1.homescore).to eq(1)
      expect(match1.awayscore).to eq(2)
    end

    it "knows the score" do
      expect(smatch.score_at(match1.kickofftime)).to eq [0, 0]
      expect(smatch.score_at(match1.kickofftime + 1.minute)).to eq [1, 0]
      expect(smatch.score_at(match1.kickofftime + 3.minutes)).to eq [2, 0]
      expect(smatch.score_at(match1.kickofftime + 45.minutes)).to eq [2, 0]
      expect(smatch.score_at(match1.kickofftime + 60.minutes)).to eq [2, 0]
      expect(smatch.score_at(match1.kickofftime + 65.minutes)).to eq [2, 1]
    end
  end
end

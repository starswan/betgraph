require "rails_helper"

RSpec.describe BbcSoccerScoresJob, :vcr, type: :job do
  before do
    create(:soccer, calendars: build_list(:calendar, 1, divisions: divisions))
  end

  context "when 15th April 2023" do
    let(:date) { Date.new(2023, 4, 15) }

    context "with one active division" do
      let(:divisions) { build_list :division, 1, football_division: build(:football_division, :premier_league) }

      before do
        create(:soccer_match, kickofftime: Time.zone.local(2023, 4, 15, 12, 30, 0),
                              division: divisions.first,
                              result: build(:result, homescore: 3, awayscore: 0),
                              name: "Manchester City v Leicester City")
      end

      it "writes scores and scorers" do
        expect {
          expect {
            described_class.perform_later date
          }.to change(SoccerMatch, :count).by(6)
        }.to change(Scorer, :count).by(23)
      end
    end

    context "with an inactive division" do
      let(:divisions) do
        [
          build(:division, :inactive, football_division: build(:football_division, :premier_league)),
          build(:division, football_division: build(:football_division, bbc_slug: "scottish-premiership")),
        ]
      end

      it "writes scores and scorers" do
        expect {
          expect {
            described_class.perform_later date
          }.to change(SoccerMatch, :count).by(4)
        }.to change(Scorer, :count).by(13)
      end
    end

    context "with nil-nil" do
      let(:divisions) do
        [
          build(:division, football_division: build(:football_division, bbc_slug: "scottish-championship")),
        ]
      end

      it "writes scores and scorers" do
        expect {
          expect {
            described_class.perform_later date
          }.to change(SoccerMatch, :count).by(4)
        }.to change(Scorer, :count).by(13)
      end
    end
  end

  context "with Austrian Bundesliga on 29th April 2023" do
    let(:date) { Date.new(2023, 4, 29) }
    let(:divisions) do
      [
        build(:division, football_division: build(:football_division, bbc_slug: "austrian-bundesliga")),
      ]
    end

    it "writes scores and scorers" do
      expect {
        expect {
          described_class.perform_later date
        }.to change(SoccerMatch, :count).by(2)
      }.to change(Scorer, :count).by(10)
    end
  end

  context "with German league bug where a 1. is added to some team names" do
    let(:date) { Date.new(2023, 11, 12) }
    let(:divisions) { build_list(:division, 1, football_division: build(:football_division, bbc_slug: "german-bundesliga")) }

    before do
      described_class.perform_later date
    end

    it "fixes up the stray 1. in the team name" do
      expect(TeamName.all.pluck(:name)).to match_array(["Bayer 04 Leverkusen", "FC Union Berlin", "Werder Bremen", "Eintracht Frankfurt", "RB Leipzig", "SC Freiburg"])
    end
  end
end

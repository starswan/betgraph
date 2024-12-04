require "rails_helper"

RSpec.describe BbcSoccerScoresJob, :vcr, type: :job do
  before do
    create(:soccer, calendars: build_list(:calendar, 1, divisions: divisions))
  end

  context "when 15th April 2023" do
    let(:date) { Date.new(2024, 12, 1) }

    context "with one active division" do
      let(:divisions) { build_list :division, 1, football_division: build(:football_division, :premier_league) }

      before do
        create(:soccer_match, kickofftime: Time.zone.local(2024, 12, 1, 12, 30, 0),
                              division: divisions.first,
                              result: build(:result, homescore: 3, awayscore: 0),
                              name: "Chelsea v Aston Villa")
      end

      it "writes scores and scorers" do
        expect {
          expect {
            described_class.perform_later date
          }.to change(SoccerMatch, :count).by(3)
        }.to change(Scorer, :count).by(11)
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
          }.to change(SoccerMatch, :count).by(2)
        }.to change(Scorer, :count).by(3)
      end
    end

    context "with nil-nil" do
      let(:divisions) do
        [
          build(:division, football_division: build(:football_division, bbc_slug: "championship")),
        ]
      end

      it "writes scores and scorers" do
        expect {
          expect {
            described_class.perform_later date
          }.to change(SoccerMatch, :count).by(1)
        }.to change(Scorer, :count).by(3)
      end
    end
  end

  context "with Austrian Bundesliga on 29th April 2023" do
    let(:date) { Date.new(2024, 11, 30) }
    let(:divisions) do
      [
        build(:division, football_division: build(:football_division, bbc_slug: "austrian-bundesliga")),
      ]
    end

    it "writes scores and scorers" do
      expect {
        expect {
          described_class.perform_later date
        }.to change(SoccerMatch, :count).by(3)
      }.to change(Scorer, :count).by(11)
    end
  end

  # Don't think the new feed has this bug
  # context "with German league bug where a 1. is added to some team names" do
  #   let(:date) { Date.new(2024, 12, 1) }
  #   let(:divisions) { build_list(:division, 1, football_division: build(:football_division, bbc_slug: "german-bundesliga")) }
  #
  #   before do
  #     described_class.perform_later date
  #   end
  #
  #   it "fixes up the stray 1. in the team name" do
  #     expect(TeamName.all.pluck(:name)).to match_array(["Eintracht Frankfurt", "Heidenheim", "Hoffenheim", "Mainz 05"])
  #   end
  # end
end

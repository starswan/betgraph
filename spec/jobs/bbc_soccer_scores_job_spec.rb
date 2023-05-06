# frozen_string_literal: true

require "rails_helper"

RSpec.describe BbcSoccerScoresJob, :vcr, type: :job do
  before do
    create(:soccer, calendars: build_list(:calendar, 1, divisions: divisions))
  end

  context "when 23rd April 2023" do
    let(:date) { Date.new(2023, 4, 15) }

    context "with one active division" do
      let(:divisions) { build_list :division, 1, football_division: build(:football_division, :premier_league) }

      it "writes scores and scorers" do
        expect {
          expect {
            described_class.perform_later date
          }.to change(SoccerMatch, :count).by(7)
        }.to change(Scorer, :count).by(20)
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
        }.to change(Scorer, :count).by(11)
      end
    end
  end

  context "when 5th May 2023" do
    let(:date) { Date.new(2023, 4, 15) }

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
        }.to change(Scorer, :count).by(12)
      end
    end
  end
end

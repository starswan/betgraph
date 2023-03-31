# frozen_string_literal: true

require "rails_helper"

RSpec.describe BbcSoccerScoresJob, :vcr, type: :job do
  let(:date) { Date.new(2022, 10, 8) }

  before do
    s = create(:soccer, calendars: build_list(:calendar, 1, divisions: build_list(:division, 1)))
    create(:football_division, division: s.divisions.first, bbc_slug: "premier-league")
  end

  it "writes scores and scorers" do
    expect {
      expect {
        described_class.perform_later date
      }.to change(SoccerMatch, :count).by(5)
    }.to change(Scorer, :count).by(16)
  end
end

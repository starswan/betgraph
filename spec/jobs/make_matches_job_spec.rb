# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe MakeMatchesJob, :vcr, :betfair, type: :job do
  before do
    calendar = create(:calendar, sport: sport)
    division = create(:division, calendar: calendar)

    RefreshSportListJob.perform_now
    sport.competitions.find_by!(name: division_name).update!(active: true, division: division)
  end

  context "soccer match" do
    let(:sport) { create(:soccer, betfair_market_types: build_list(:betfair_market_type, 1, name: "Match Odds")) }
    let(:division_name) { "English Championship" }

    it "makes a soccer match" do
      expect {
        described_class.perform_later sport
      }.to change(SoccerMatch, :count).by(24)
      expect(BetMarket.where(live_priced: true).count).to eq(468)
      expect(SoccerMatch.find_by(name: "QPR v Coventry")).to have_attributes(betfair_event_id: 32_256_996)
    end
  end

  context "baseball" do
    let(:sport) { create(:baseball, betfair_market_types: build_list(:betfair_market_type, 1, name: "Match Odds")) }
    let(:division_name) { "Major League Baseball" }

    it "makes baseball matches" do
      expect {
        described_class.perform_later sport
      }.to change(BaseballMatch, :count).by(15)
    end
  end

  context "motor sport" do
    let(:sport) { create(:motor_sport, betfair_market_types: build_list(:betfair_market_type, 1, name: "Winner")) }
    let(:division_name) { "Formula 1" }

    it "makes one motor race" do
      expect {
        described_class.perform_later sport
      }.to change(MotorRace, :count).by(1)
    end
  end
end

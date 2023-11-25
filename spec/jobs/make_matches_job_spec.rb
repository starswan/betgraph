# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe MakeMatchesJob, :vcr, :betfair, type: :job do
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }

  context "soccer match" do
    let(:sport) { Sport.find_by!(name: "Soccer") }
    let(:division_name) { "English Championship" }

    before do
      create(:soccer, betfair_market_types: build_list(:betfair_market_type, 1, name: "Match Odds"))
      RefreshSportListJob.perform_now
      sport.competitions.find_by!(name: division_name).update!(active: true, division: division)
    end

    it "makes a soccer match" do
      expect {
        described_class.perform_later sport
      }.to change(SoccerMatch, :count).by(24)
      expect(BetMarket.where(live_priced: true).count).to eq(468)
      expect(SoccerMatch.find_by(name: "QPR v Coventry")).to have_attributes(betfair_event_id: 32_256_996)
    end

    context "with an existing match" do
      let(:event_id) { 32_797_391 }
      let(:creation_time) { Time.zone.today }
      let(:ko_time) { Time.zone.local(2023, 11, 29, 19, 45, 0) }

      before do
        create(:soccer_match, division: division, name: "Leeds v Swansea", betfair_event_id: event_id, kickofftime: ko_time, created_at: creation_time)
      end

      it "keeps the match" do
        expect {
          described_class.perform_later sport
        }.to change(SoccerMatch, :count).by(22)
        expect(BetMarket.where(live_priced: true).count).to eq(389)
        expect(SoccerMatch.find_by(name: "Leeds v Swansea")).to have_attributes(betfair_event_id: event_id, created_at: creation_time)
      end
    end
  end

  context "baseball" do
    let(:sport) { Sport.find_by!(name: "Baseball") }
    let(:division_name) { "Major League Baseball" }

    before do
      create(:baseball, betfair_market_types: build_list(:betfair_market_type, 1, name: "Match Odds"))
      RefreshSportListJob.perform_now
      sport.competitions.find_by!(name: division_name).update!(active: true, division: division)
    end

    it "makes baseball matches" do
      expect {
        described_class.perform_later sport
      }.to change(BaseballMatch, :count).by(15)
    end
  end

  context "motor sport" do
    let(:division_name) { "Formula 1" }
    let(:sport) { Sport.find_by!(name: "Motor Sport") }

    before do
      create(:motor_sport, betfair_market_types: build_list(:betfair_market_type, 1, name: "Winner"))
      RefreshSportListJob.perform_now
      sport.competitions.find_by!(name: division_name).update!(active: true, division: division)
    end

    it "makes one motor race" do
      expect {
        described_class.perform_later sport
      }.to change(MotorRace, :count).by(1)
    end
  end
end

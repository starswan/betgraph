require "rails_helper"

RSpec.describe LoadHistoricalDataJob, type: :job do
  # let(:datafile) { Rails.root.join("spec/fixtures/31954039.txt") }
  let(:sport) do
    create(:soccer,
           betfair_market_types: [
             build(:betfair_market_type),
             build(:betfair_market_type, :asian),
           ])
  end
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }

  context "with basic data file" do
    before do
      create(:soccer_match,
             name: "Nottm Forest v Chelsea",
             division: division,
             kickofftime: Time.zone.local(2023, 1, 1, 16, 30, 0))
    end

    # forest vs chelsea
    let(:datafile) { Rails.root.join("spec/fixtures/basic/31954039.bz2") }

    it "processes a bzip2 file with iostreams" do
      expect {
        expect {
          described_class.perform_now(datafile)
        }.to change(MarketPriceTime, :count).by(746)
      }.to change(MarketPrice, :count).by(2904)
    end
  end

  context "with advanced data file" do
    before do
      create(:soccer_match,
             name: "West Ham v Liverpool",
             division: division,
             kickofftime: Time.zone.local(2016, 1, 2, 12, 45, 0))
    end

    # liverpool vs Westham
    let(:datafile) { Rails.root.join("spec/fixtures/advanced/27635178.bz2") }

    it "processes an advanced file" do
      expect {
        expect {
          described_class.perform_now(datafile)
        }.to change(MarketPriceTime, :count).by(4454)
      }.to change(MarketPrice, :count).by(6342)
    end
  end
end

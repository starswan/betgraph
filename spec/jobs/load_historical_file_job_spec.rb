#
# $Id$
#
require "rails_helper"

RSpec.describe LoadHistoricalFileJob, type: :job do
  let(:sport) do
    create(:soccer,
           betfair_market_types: [
             build(:betfair_market_type),
             build(:betfair_market_type, :asian),
           ])
  end
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }
  let(:burtonchippenham) { Rails.root.join("spec/fixtures/basic/31925115.bz2") }
  let(:westhamliverpool) { Rails.root.join("spec/fixtures/advanced/27635178.bz2") }

  context "with a match" do
    before do
      create(:soccer_match,
             name: match_name,
             division: division,
             kickofftime: match_time)
    end

    context "with basic data file" do
      let(:match_name) { "Burton Albion v Chippenham" }
      let(:match_time) { Time.zone.local(2022, 11, 27, 15, 0, 0) }

      it "processes a bzip2 file with iostreams" do
        expect {
          expect {
            described_class.perform_now(burtonchippenham)
          }.to change(MarketPriceTime, :count).by(181)
        }.to change(MarketPrice, :count).by(388)
      end
    end

    # The 'free' advanced data appears to have lots of noise (or maybe evem bugs?)
    # so this test results in lots of weird code
    xcontext "with a west ham liverpool match" do
      let(:match_name) { "West Ham v Liverpool" }
      let(:match_time) { Time.zone.local(2016, 1, 2, 12, 45, 0) }

      it "processes advanced file" do
        expect {
          expect {
            described_class.perform_now(westhamliverpool)
          }.to change(MarketPriceTime, :count).by(4439)
        }.to change(MarketPrice, :count).by(6316)
      end
    end
  end

  context "without a match" do
    it "processes file without crashing" do
      described_class.perform_now(burtonchippenham)
    end
  end
end

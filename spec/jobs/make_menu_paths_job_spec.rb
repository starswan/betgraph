# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe MakeMenuPathsJob, type: :job do
  let!(:login) { create(:login) }
  let!(:menu_path) { create(:menu_path, depth: 1, name: ["Soccer", "Belgian", "Fixtures", fixture_date]) }

  before do
    Timecop.travel Date.new(2021, 6, 20)

    stub_betfair_login "Soccer", [
      build(:betfair_event,
            name: "Belgian",
            children: [build(:betfair_event,
                             name: "Fixtures",
                             children: [build(:betfair_event,
                                              name: fixture_date,
                                              children: [build(:betfair_event,
                                                               name: "Match",
                                                               children: [build(:betfair_market)])])])]),
    ]
  end

  after do
    Timecop.return
  end

  context "when within 2 months" do
    let(:fixture_date) { "Fixtures 24 July" }

    it "builds paths for near-future fixtures" do
      expect {
        described_class.perform_now menu_path
      }.to change(MenuPath, :count).by(1)
    end
  end

  context "when outside 2 months" do
    let(:fixture_date) { "Fixtures 24 September" }

    it "doesnt build" do
      expect {
        described_class.perform_later menu_path
      }.to change(MenuPath, :count).by(0)
    end
  end
end

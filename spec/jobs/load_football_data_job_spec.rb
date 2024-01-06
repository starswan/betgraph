#
# $Id$
#
require "rails_helper"

RSpec.describe LoadFootballDataJob, type: :job do
  let(:sport) { create(:soccer, calendars: build_list(:calendar, 1)) }
  let(:season) { create(:season, calendar: sport.calendars.first, startdate: Date.new(2019, 8, 1)) }
  let(:division) { create(:division, calendar: season.calendar) }

  before do
    create(:football_division, football_data_code: "SC0", division: division)
  end

  it "performs" do
    zipfile = File.read(Rails.root.join("spec/fixtures/1920.zip"))
    stub_request(:get, "https://www.football-data.co.uk/mmz4281/1920/data.zip")
      .to_return(body: zipfile)

    expect {
      described_class.perform_now "2019-09-01"
    }.to change(Result, :count).by(42)
  end
end

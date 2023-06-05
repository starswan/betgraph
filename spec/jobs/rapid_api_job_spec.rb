require "rails_helper"

RSpec.describe RapidApiJob, :vcr, type: :job do
  before do
    soccer = create :soccer, calendars: build_list(:calendar, 1)
    division = create(:division, calendar: soccer.calendars.first, football_division: build(:football_division, rapid_api_country: "England", rapid_api_name: "League One"))
    # division = create(:division, calendar: soccer.calendars.first, football_division: build(:football_division, rapid_api_country: "England", rapid_api_name: "Premier League"))

    create(:soccer_match, kickofftime: Time.zone.local(2023, 4, 15, 12, 30, 0),
                          division: division,
                          result: build(:result, homescore: 3, awayscore: 0),
                          name: "Milton Keynes Dons v Cheltenham")
  end

  let(:date) { Date.new(2023, 4, 15) }

  it "calls the API" do
    expect {
      described_class.perform_now date
    }.to change(SoccerMatch, :count).by(11)
  end
end

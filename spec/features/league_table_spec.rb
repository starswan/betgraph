# frozen_string_literal: true

require "rails_helper"

RSpec.describe "LeagueTables", type: :feature do
  let(:sport) { create(:soccer, calendars: build_list(:calendar, 1)) }
  let(:division) { create(:division, calendar: calendar) }
  let(:calendar) { sport.calendars.first }

  before do
    create(:season, :first, calendar: calendar)
    create(:season, :final, calendar: calendar)
    create(:season, calendar: calendar, startdate: Date.new(2022, 8, 1))
    create(:season, calendar: calendar, startdate: Date.new(2023, 8, 1))

    create(:soccer_match, with_runners_and_prices: true, with_markets_and_runners: true,
                          division: division,
                          name: "One v Two",
                          result: build(:result),
                          kickofftime: Time.zone.local(2023, 5, 13, 15, 0, 0))
    create(:soccer_match, with_runners_and_prices: true, with_markets_and_runners: true,
                          division: division, name: "Three v Four",
                          result: build(:result),
                          kickofftime: Time.zone.local(2023, 5, 13, 15, 0, 0))

    create(:soccer_match, with_runners_and_prices: true, with_markets_and_runners: true,
                          name: "One v Three",
                          division: division, result: build(:result), kickofftime: Time.zone.local(2023, 5, 20, 15, 0, 0))
    create(:soccer_match, with_runners_and_prices: true, with_markets_and_runners: true,
                          name: "Two v Four",
                          division: division, result: build(:result), kickofftime: Time.zone.local(2023, 5, 20, 15, 0, 0))
  end

  it "shows the league table and fixtures", :js do
    visit division_path(division)
    # This is the link to bring up the (historic) fixtures for this division
    click_on "[4]"
    click_on "Sat 20 May [2]"
    click_on "Sat 13 May [2]"
  end
end

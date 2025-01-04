# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin", type: :feature do
  let(:sport) { create(:soccer, calendars: build_list(:calendar, 1)) }
  let(:menu_items) { ["Calendars", "Competitions", "Divisions", "Football Divisions", "Seasons", "Sports"] }
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

    create(:competition, sport: sport)
    create(:football_division, division: division)
  end

  it "shows admin screen", :js do
    visit admin_root_path

    menu_items.each do |item|
      # sleep 1
      click_on item
      sleep 1
    end
  end
end

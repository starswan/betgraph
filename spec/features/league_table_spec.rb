# frozen_string_literal: true

require "rails_helper"

RSpec.describe "LeagueTables", type: :feature do
  let(:sport) { create(:soccer, calendars: build_list(:calendar, 1, seasons: build_list(:season, 2))) }
  let(:division) { create(:division, calendar: sport.calendars.first) }

  it "shows the league table" do
    visit division_path(division)
  end
end

#
# $Id$
#
require "rails_helper"

RSpec.describe "Aug 26 2017", type: :feature do
  let(:sport) { create(:soccer, calendars: build_list(:calendar, 1)) }
  let(:division) { create(:division, calendar: calendar.reload, name: "League Division One") }
  let(:calendar) { sport.calendars.first }
  let(:aug_26_3pm) { Time.zone.local(2017, 8, 26, 15, 0, 0) }
  let(:aug_26_2017) { aug_26_3pm.to_date }

  let(:teams) do
    [
      ["Fleetwood Town"],
      ["Coventry", "Coventry City"],
      ["Bradford", "Bradford City"],
      ["Bristol Rovers", "Bristol Rvs"],
      ["Plymouth Argyle", "Plymouth"],
      ["Shrewsbury Town", "Shrewsbury"],
      ["Southend United", "Southend Utd"],
      ["Peterborough United", "Peterboro", "Peterborough"],
      ["Accrington ST", "Accrington"],
      ["Burton Albion", "Burton"],
    ]
  end

  before do
    teams.each do |team_list|
      create(:team, sport: sport, team_names: team_list.map { |team| build(:team_name, name: team) })
    end

    create(:season, :first, calendar: calendar)
    create(:season, :final, calendar: calendar)
    create(:season, calendar: calendar, startdate: Date.new(2017, 8, 1))
    create(:season, calendar: calendar, startdate: Date.new(2018, 8, 1))
    create(:season, calendar: calendar, startdate: Date.new(2019, 8, 1))

    create(:betfair_market_type, :match_odds, sport: sport)
    create(:betfair_market_type, :correct_score, sport: sport)
    create(:betfair_market_type, :overunder25, sport: sport)
    # create a dummy bet_market so that market types array is populated
    create(:soccer_match,
           division: create(:division, calendar: division.calendar),
           bet_markets: [
             build(:bet_market, :match_odds),
             build(:bet_market, :correct_score),
             build(:bet_market, :overunder),
           ])

    # Need to find out event id to run this w/o downloading the whole date
    create(:soccer_match, division: division, betfair_event_id: 28_350_800, name: "Bristol Rovers v Fleetwood Town", kickofftime: aug_26_3pm, result: build(:result))

    FetchHistoricalDataJob.perform_now(aug_26_2017, "GB")
  end

  it "shows the league fixtures", :vcr do
    visit division_path(division)
    # sleep 1
    # This is the link to bring up the (historic) fixtures for this division
    click_on "[1]"
    # sleep 16
  end
end

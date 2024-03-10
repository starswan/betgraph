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
      ["Bristol Rovers", "Bristol Rvs"],
      ["Fleetwood Town"],
      ["Northampton"],
      ["Peterborough", "Peterborough United", "Peterboro"],
      ["Oxford Utd"],
      ["Shrewsbury Town", "Shrewsbury"],
      ["AFC Wimbledon"],
      ["Doncaster"],
      ["Blackburn"],
      ["MK Dons"],
      ["Blackpool"],
      ["Oldham"],
      # ["Coventry", "Coventry City"],
      # ["Bradford", "Bradford City"],
      # ["Plymouth Argyle", "Plymouth"],
      # ["Southend United", "Southend Utd"],
      # ["Accrington ST", "Accrington"],
      # ["Burton Albion", "Burton"],
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
    create(:betfair_market_type, :both_teams_to_score, sport: sport)
    # create a dummy bet_market so that market types array is populated
    create(:soccer_match,
           division: create(:division, calendar: division.calendar),
           bet_markets: [
             build(:bet_market, :match_odds),
             build(:bet_market, :correct_score),
             build(:bet_market, :both_teams_to_score),
             build(:bet_market, :overunder),
           ])

    # Need to find out event id to run this w/o downloading the whole date
    create(:soccer_match, division: division, betfair_event_id: 28_350_800, name: "Bristol Rovers v Fleetwood Town", kickofftime: aug_26_3pm, result: build(:result))
    create(:soccer_match, division: division, betfair_event_id: 28_350_797, name: "Northampton v Peterborough", kickofftime: aug_26_3pm, result: build(:result))
    create(:soccer_match, division: division, betfair_event_id: 28_350_796, name: "Oxford Utd v Shrewsbury", kickofftime: aug_26_3pm, result: build(:result))
    create(:soccer_match, division: division, betfair_event_id: 28_350_801, name: "AFC Wimbledon v Doncaster", kickofftime: aug_26_3pm, result: build(:result))
    create(:soccer_match, division: division, betfair_event_id: 28_350_795, name: "Blackburn v MK Dons", kickofftime: aug_26_3pm, result: build(:result))
    create(:soccer_match, division: division, betfair_event_id: 28_350_799, name: "Blackpool v Oldham", kickofftime: aug_26_3pm, result: build(:result))

    FetchHistoricalDataJob.perform_now(aug_26_2017, "GB")
  end

  it "shows the league fixtures", :vcr, :js do
    visit division_path(division)
    sleep 4
    # This is the link to bring up the (historic) fixtures for this division
    click_on "[6]"
    sleep 5
  end
end

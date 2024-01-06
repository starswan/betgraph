require "rails_helper"

RSpec.describe "LeagueTables", type: :feature do
  let(:sport) { create(:soccer, calendars: build_list(:calendar, 1)) }
  let(:division) { create(:division, calendar: calendar.reload, name: "League Division One") }
  let(:calendar) { sport.calendars.first }
  let(:aug_19) { Date.new(2018, 8, 19) }
  let(:aug_19_3pm) { Time.zone.local(2018, 8, 19, 15, 0, 0) }
  let(:sep_8) { Date.new(2018, 9, 8) }
  let(:sep_8_1230) { Time.zone.local(2018, 9, 8, 12, 30, 0) }
  let(:sep_8_3pm) { Time.zone.local(2018, 9, 8, 15, 0, 0) }

  before do
    create(:team, sport: sport, team_names: [build(:team_name, name: "Oxford"), build(:team_name, name: "Oxford Utd")])
    create(:team, sport: sport, team_names: [build(:team_name, name: "Coventry"), build(:team_name, name: "Coventry City")])
    create(:team, sport: sport, team_names: [build(:team_name, name: "Bradford"), build(:team_name, name: "Bradford City")])
    create(:team, sport: sport, team_names: [build(:team_name, name: "Bristol Rovers"), build(:team_name, name: "Bristol Rvs")])
    create(:team, sport: sport, team_names: [build(:team_name, name: "Plymouth Argyle"), build(:team_name, name: "Plymouth")])
    # create(:team, sport: sport, team_names: [build(:team_name, name: "Luton Town"), build(:team_name, name: "Luton")])
    # create(:team, sport: sport, team_names: [build(:team_name, name: "Doncaster Rovers"), build(:team_name, name: "Doncaster")])
    create(:team, sport: sport, team_names: [build(:team_name, name: "Shrewsbury Town"), build(:team_name, name: "Shrewsbury")])
    create(:team, sport: sport, team_names: [build(:team_name, name: "Southend United"), build(:team_name, name: "Southend"), build(:team_name, name: "Southend Utd")])
    create(:team, sport: sport, team_names: [build(:team_name, name: "Peterborough United"), build(:team_name, name: "Peterboro"), build(:team_name, name: "Peterborough")])
    create(:team, sport: sport, team_names: [build(:team_name, name: "Accrington ST"), build(:team_name, name: "Accrington")])
    create(:team, sport: sport, team_names: [build(:team_name, name: "Burton Albion"), build(:team_name, name: "Burton")])

    # create(:football_division, :league_one, division: division)

    create(:season, :first, calendar: calendar)
    create(:season, :final, calendar: calendar)
    create(:season, calendar: calendar, startdate: Date.new(2018, 8, 1))
    create(:season, calendar: calendar, startdate: Date.new(2019, 8, 1))
    create(:season, calendar: calendar, startdate: Date.new(2022, 8, 1))
    create(:season, calendar: calendar, startdate: Date.new(2023, 8, 1))

    # create(:soccer_match, with_runners_and_prices: true, with_markets_and_runners: true,
    #                       division: division,
    #                       name: "Burnley v Watford",
    # betfair_event_id: 28820790,
    #                       result: build(:result),
    #                       kickofftime: Time.zone.local(2018, 8, 19, 15, 0, 0))
    #  :eventId=>"28841349", :eventName=>"West Ham U23 v Man City U23"
    # Hibernian v Ross Co 28841354
    # Kilmarnock v Rangers 28841356
    # Rangers (W) v Stirling University (W) 28851917
    # Jeanfield Swifts (W) v CGFA Wasps (W) 28851919
    # Brighton v Man Utd 28820796
    # make a market type so that markets get created
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

    create(:soccer_match, division: division, betfair_event_id: 28_841_336, name: "Sunderland v Scunthorpe", kickofftime: aug_19_3pm)

    create(:soccer_match, division: division, betfair_event_id: 28_875_751, name: "Bristol Rovers v Plymouth", kickofftime: sep_8_1230)

    create(:soccer_match, division: division, betfair_event_id: 28_875_760, name: "Accrington v Burton", kickofftime: sep_8_3pm)
    create(:soccer_match, division: division, betfair_event_id: 28_875_763, name: "Barnsley v Walsall", kickofftime: sep_8_3pm)
    create(:soccer_match, division: division, betfair_event_id: 28_875_755, name: "Blackpool v Bradford", kickofftime: sep_8_3pm)
    create(:soccer_match, division: division, betfair_event_id: 28_875_765, name: "Charlton v Wycombe", kickofftime: sep_8_3pm)
    create(:soccer_match, division: division, betfair_event_id: 28_875_752, name: "Doncaster v Luton", kickofftime: sep_8_3pm)
    create(:soccer_match, division: division, betfair_event_id: 28_875_759, name: "Gillingham v AFC Wimbledon", kickofftime: sep_8_3pm)
    create(:soccer_match, division: division, betfair_event_id: 28_875_756, name: "Portsmouth v Shrewsbury", kickofftime: sep_8_3pm)
    create(:soccer_match, division: division, betfair_event_id: 28_875_764, name: "Scunthorpe v Rochdale", kickofftime: sep_8_3pm)
    create(:soccer_match, division: division, betfair_event_id: 28_875_757, name: "Southend v Peterborough", kickofftime: sep_8_3pm)
    create(:soccer_match, division: division, betfair_event_id: 28_875_762, name: "Sunderland v Fleetwood Town", kickofftime: sep_8_3pm)

    fixtures1819 = File.read(Rails.root.join("spec/fixtures/E2.1819.csv"))
    # LoadFootballDataJob.perform_now(sep_9.to_s)
    LoadFootballDataJob.new.parse_input_stream(fixtures1819, division)

    FetchHistoricalDataJob.perform_now(aug_19, "GB")
    FetchHistoricalDataJob.perform_now(sep_8, "GB")
  end

  it "shows the league fixtures", :vcr, :js do
    visit division_path(division)
    sleep 1
    # This is the link to bring up the (historic) fixtures for this division
    click_on "[12]"
    sleep 1
    click_on "Sun 19 Aug [1]"
    sleep 1
    click_on "Sat 8 Sep [11]"
    sleep 1
  end
end

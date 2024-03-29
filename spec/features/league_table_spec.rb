# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe "LeagueTables", type: :feature do
  let(:sport) { create(:soccer) }
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, :league_one_2018, calendar: calendar) }
  let(:aug_19) { Date.new(2018, 8, 19) }
  let(:aug_19_3pm) { Time.zone.local(2018, 8, 19, 15, 0, 0) }
  let(:sep_8) { Date.new(2018, 9, 8) }
  let(:sep_8_1230) { Time.zone.local(2018, 9, 8, 12, 30, 0) }
  let(:sep_8_3pm) { Time.zone.local(2018, 9, 8, 15, 0, 0) }

  let(:std_markets) do
    [
      build(:bet_market, :match_odds, market_runners: build_list(:market_runner, 2)),
      build(:bet_market, :correct_score),
      build(:bet_market, :overunder),
    ]
  end

  before do
    create(:team, sport: sport, team_names: [build(:team_name, name: "Oxford"), build(:team_name, name: "Oxford Utd")])
    create(:team, sport: sport, team_names: [build(:team_name, name: "Coventry"), build(:team_name, name: "Coventry City")])
    create(:team, sport: sport, team_names: [build(:team_name, name: "Bradford"), build(:team_name, name: "Bradford City")])
    create(:team, sport: sport, team_names: [build(:team_name, name: "Bristol Rovers"), build(:team_name, name: "Bristol Rvs")])
    create(:team, sport: sport, team_names: [build(:team_name, name: "Plymouth Argyle"), build(:team_name, name: "Plymouth")])
    create(:team, sport: sport, team_names: [build(:team_name, name: "Shrewsbury Town"), build(:team_name, name: "Shrewsbury")])
    create(:team, sport: sport, team_names: [build(:team_name, name: "Southend United"), build(:team_name, name: "Southend"), build(:team_name, name: "Southend Utd")])
    create(:team, sport: sport, team_names: [build(:team_name, name: "Peterborough United"), build(:team_name, name: "Peterboro"), build(:team_name, name: "Peterborough")])
    create(:team, sport: sport, team_names: [build(:team_name, name: "Accrington ST"), build(:team_name, name: "Accrington")])
    create(:team, sport: sport, team_names: [build(:team_name, name: "Burton Albion"), build(:team_name, name: "Burton")])

    create(:season, :first, calendar: calendar)
    create(:season, :final, calendar: calendar)
    create(:season, calendar: calendar, startdate: Date.new(2018, 8, 1))
    create(:season, calendar: calendar, startdate: Date.new(2019, 8, 1))
    create(:season, calendar: calendar, startdate: Date.new(2022, 8, 1))
    create(:season, calendar: calendar, startdate: Date.new(2023, 8, 1))

    # make a market type so that markets get created
    create(:betfair_market_type, :match_odds, sport: sport)
    create(:betfair_market_type, :correct_score, sport: sport)
    create(:betfair_market_type, :overunder25, sport: sport)
    create(:betfair_market_type, :half_time, sport: sport)
    # create a dummy bet_market so that market types array is populated
    create(:soccer_match,
           division: create(:division, calendar: calendar),
           bet_markets: std_markets)
  end

  context "with matches" do
    before do
      data = [
        { betfair_event_id: 28_841_336, name: "Sunderland v Scunthorpe", kickofftime: aug_19_3pm },
        { betfair_event_id: 28_875_751, name: "Bristol Rovers v Plymouth", kickofftime: sep_8_1230 },
        { betfair_event_id: 28_875_760, name: "Accrington v Burton", kickofftime: sep_8_3pm },
        { betfair_event_id: 28_875_763, name: "Barnsley v Walsall", kickofftime: sep_8_3pm },
        { betfair_event_id: 28_875_755, name: "Blackpool v Bradford", kickofftime: sep_8_3pm },
        # { betfair_event_id: 28_875_765, name: "Charlton v Wycombe", kickofftime: sep_8_3pm },
        # { betfair_event_id: 28_875_752, name: "Doncaster v Luton", kickofftime: sep_8_3pm },
        # { betfair_event_id: 28_875_759, name: "Gillingham v AFC Wimbledon", kickofftime: sep_8_3pm },
        # { betfair_event_id: 28_875_756, name: "Portsmouth v Shrewsbury", kickofftime: sep_8_3pm },
        # { betfair_event_id: 28_875_764, name: "Scunthorpe v Rochdale", kickofftime: sep_8_3pm },
        # { betfair_event_id: 28_875_757, name: "Southend v Peterborough", kickofftime: sep_8_3pm },
        # { betfair_event_id: 28_875_762, name: "Sunderland v Fleetwood Town", kickofftime: sep_8_3pm },
      ]

      matches = data.map do |d|
        create(:soccer_match,
               division: division,
               betfair_event_id: d.fetch(:betfair_event_id),
               name: d.fetch(:name),
               bet_markets: [
                 build(:bet_market, :match_odds, time: d.fetch(:kickofftime), market_runners: build_list(:market_runner, 2)),
                 build(:bet_market, :half_time, time: d.fetch(:kickofftime), market_runners: build_list(:market_runner, 2)),
               ],
               kickofftime: d.fetch(:kickofftime))
      end
      fixtures1819 = File.read(Rails.root.join("spec/fixtures/E2.1819.csv"))
      LoadFootballDataJob.new.parse_input_stream(fixtures1819, division)

      # FetchHistoricalDataJob.perform_now(aug_19, "GB")
      # FetchHistoricalDataJob.perform_now(sep_8, "GB")
      matches.each_with_index do |m, index|
        # first_market = m.bet_markets.first
        # second_market = m.bet_markets.second
        1.upto(90 - index).each do |t|
          r = rand(0.5)
          create(:market_price_time, time: m.kickofftime + t.minutes,
                                     market_prices: m.bet_markets.map { |bm|
                                                      [
                                                        build(:market_price, back1price: 2 - r, market_runner: bm.market_runners.first),
                                                        build(:market_price, back1price: 2 + r, market_runner: bm.market_runners.second),
                                                      ]
                                                    }.flatten)
        end
      end
    end

    it "shows the league fixtures", :vcr, :js do
      visit division_path(division)
      sleep 1
      # This is the link to bring up the (historic) fixtures for this division
      click_on "[5]"
      sleep 1
      click_on "Sun 19 Aug [1]"
      sleep 1
      click_on "Sat 8 Sep [4]"
      sleep 1
      click_on "2/352"
      sleep 2
      click_on "Half Time"
      sleep 1
    end
  end
end

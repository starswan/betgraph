# frozen_string_literal: true

namespace :matches do
  desc "List matches"
  task list: :environment do
    soccer = Sport.find_by! name: "Soccer"
    # 86 minutes on arthur for 3 divisions and 7 seasons
    championship = soccer.divisions.find_by! name: "English Championship"
    league_one = soccer.divisions.find_by! name: "English League One"
    league_two = soccer.divisions.find_by! name: "English League Two"
    divisions = [championship, league_one, league_two]

    # s1415 = Season.find_by! name: "2014/15", calendar: championship.calendar
    # s1516 = Season.find_by! name: "2015/16", calendar: championship.calendar
    # s1617 = Season.find_by! name: "2016/17", calendar: championship.calendar
    # s1718 = Season.find_by! name: "2017/2018", calendar: championship.calendar
    # s1819 = Season.find_by! name: "2018/19", calendar: championship.calendar
    # s1920 = Season.find_by! name: "2019/2020", calendar: championship.calendar
    # Last 5 years (ish) 2014-2019 - 2020/21 contains a (maybe) broken match or two
    # s2021 = Season.find_by! name: "2020/2021", calendar: championship.calendar
    # s2122 = Season.find_by! name: "2021/2022", calendar: championship.calendar
    # recent_seasons = [s1415, s1516, s1617, s1718, s1819, s1920]
    # recent_seasons = [s1819, s1920]
    recent_seasons = Season.where("startdate <= ?", 9.months.ago)
                          .where("startdate >= ?", 15.years.ago)
                       .where(calendar: championship.calendar)
    # .where.not(name: "2020/2021").where.not(name: "2021/2022")
    match_groups = recent_seasons.map do |season|
      SoccerMatch.includes(:result, :teams)
                         .where(division: divisions, season: season)
                         .order(:kickofftime)
    end

    puts "#{recent_seasons.size} Seasons #{divisions.size} Divisions", MatchCalculator.things(match_groups)
  end
end

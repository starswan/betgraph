# frozen_string_literal: true

#
# $Id$
#
class FootballDataJob < ApplicationJob
  queue_priority PRIORITY_LOAD_FOOTBALL_DATA

  def perform(row, division)
    soccer = division.calendar.sport

    # use 3pm if we don't know the kickoff time
    time = row["Time"] || "15:00"

    rawhometeam = row["HomeTeam"]
    rawawayteam = row["AwayTeam"]
    homescore = row["FTHG"]
    awayscore = row["FTAG"]
    homehtscore = row["HTHG"]
    awayhtscore = row["HTAG"]
    date = row.fetch("Date")

    kickoff = date + (time.to_time.to_i - "00:00".to_time.to_i).seconds

    Result.transaction do
      hometeamname = TeamName.joins(:team).includes(:team).merge(Team.for_sport(soccer)).where(name: rawhometeam).first
      awayteamname = TeamName.joins(:team).includes(:team).merge(Team.for_sport(soccer)).where(name: rawawayteam).first

      if hometeamname
        hometeam = hometeamname.team
      else
        logger.debug { "Creating team [#{rawhometeam}]" }
        hometeam = soccer.teams.create!
        hometeam.team_names.create! name: rawhometeam
      end
      if awayteamname
        awayteam = awayteamname.team
      else
        logger.debug { "Creating team [#{rawawayteam}]" }
        awayteam = soccer.teams.create!
        awayteam.team_names.create! name: rawawayteam
      end

      match = division.find_match hometeam, awayteam, date

      if match.nil?
        logger.debug { "Creating #{date} #{hometeam.name} v #{awayteam.name} #{homescore}-#{awayscore}(#{homehtscore}-#{awayhtscore})" }
        match = division.matches.create! kickofftime: kickoff, venue: hometeam, name: "#{hometeam.name} v #{awayteam.name}", type: "SoccerMatch"
      end
      unless homescore.blank? || awayscore.blank? || match.result
        match.create_result! homescore: homescore, awayscore: awayscore,
                             half_time_home_score: homehtscore, half_time_away_score: awayhtscore
      end
      # match.result.create! :homescore => homescore, :awayscore => awayscore unless homescore.blank? or awayscore.blank? or match.result
    end
  end
end

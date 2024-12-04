# frozen_string_literal: true

class ProcessBbcScoresJob < ApplicationJob
  queue_priority PRIORITY_LOAD_FOOTBALL_DATA

  def perform(division, event)
    date = Date.parse(event.dig(:date, :isoDate))
    home_team_root = event.fetch(:home)
    away_team_root = event.fetch(:away)

    home_team = find_or_create_team(home_team_root.fetch(:fullName))
    away_team = find_or_create_team(away_team_root.fetch(:fullName))

    homehtscore = home_team_root.dig(:runningScores, :halftime)
    homescore = home_team_root.dig(:runningScores, :fulltime)

    awayhtscore = away_team_root.dig(:runningScores, :halftime)
    awayscore = away_team_root.dig(:runningScores, :fulltime)

    kickoff = Time.zone.parse(event.dig(:date, :iso))

    match = division.find_match home_team, away_team, date

    if match.nil?
      logger.debug { "Creating #{date} #{home_team.name} v #{away_team.name} #{homescore}-#{awayscore}(#{homehtscore}-#{awayhtscore})" }
      match = division.matches.create! kickofftime: kickoff, venue: home_team, name: "#{home_team.name} v #{away_team.name}", type: "SoccerMatch"
    end
    unless homescore.blank? || awayscore.blank? || match.result
      match.create_result! homescore: homescore, awayscore: awayscore,
                           half_time_home_score: homehtscore, half_time_away_score: awayhtscore
    end

    create_scorers(match, home_team_root, home_team)
    create_scorers(match, away_team_root, away_team)
  end

private

  def create_scorers(match, team_root, team)
    match.scorers.destroy_all
    team_root.fetch(:actions).select { |a| a.fetch(:actionType) == "goal" }.each do |player|
      player.fetch(:actions).each do |goal|
        goaltime = goal.dig(:timeLabel, :value).to_i
        match.scorers.create! goaltime: goaltime <= 45 ? (60 * goaltime) : 60 * (goaltime + 15),
                              owngoal: goal.fetch(:type) == "Own Goal",
                              penalty: goal.fetch(:type) == "Penalty",
                              name: player.fetch(:playerName),
                              team: team
      end
    end
  end

  def find_or_create_team(raw_name_with_1)
    raw_name = raw_name_with_1.starts_with?("1. ") ? raw_name_with_1[3..] : raw_name_with_1
    soccer = Sport.find_by(name: "Soccer")

    teamname = TeamName.joins(:team).includes(:team).merge(Team.for_sport(soccer)).where(name: raw_name).first

    if teamname
      teamname.team
    else
      soccer.teams.create!.tap do |team|
        team.team_names.create! name: raw_name
      end
    end
  end
end

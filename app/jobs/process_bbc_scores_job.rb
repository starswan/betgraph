# frozen_string_literal: true

class ProcessBbcScoresJob < ApplicationJob
  queue_priority PRIORITY_LOAD_FOOTBALL_DATA

  def perform(division, date, event)
    home_team_root = event.fetch(:homeTeam)
    away_team_root = event.fetch(:awayTeam)

    home_team = find_or_create_team(home_team_root.dig(:name, :full))
    away_team = find_or_create_team(away_team_root.dig(:name, :full))

    homehtscore = home_team_root.dig(:scores, :halfTime)
    homescore = home_team_root.dig(:scores, :fullTime)

    awayhtscore = away_team_root.dig(:scores, :halfTime)
    awayscore = away_team_root.dig(:scores, :fullTime)

    kickoff = event.fetch(:startTime)

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
    team_root.fetch(:playerActions, []).each do |player|
      player.fetch(:actions).select { |a| a.fetch(:type) == "goal" }.each do |goal|
        goaltime = goal.fetch(:timeElapsed)
        match.scorers.create! goaltime: goaltime <= 45 ? (60 * goaltime) : 60 * (goaltime + 15),
                              owngoal: goal.fetch(:ownGoal),
                              penalty: goal.fetch(:penalty),
                              name: player.dig(:name, :abbreviation),
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

# frozen_string_literal: true

class RapidApiJob < ApplicationJob
  queue_as :default

  HOSTNAME = "api-football-v1.p.rapidapi.com"

  def perform(date)
    faraday = Faraday.new(
      url: "https://#{HOSTNAME}",
      headers: {
        'X-RapidAPI-Key': ENV.fetch("RAPID_API_KEY"),
        'X-RapidAPI-Host': HOSTNAME,
      },
    ) do |f|
      f.request :instrumentation
      f.response :raise_error
      f.response :json, parser_options: { symbolize_names: true }
    end

    response = faraday.get("/v3/fixtures", date: date.to_s)
    # response = faraday.get("/v3/leagues", country: "England")
    data = response.body.fetch(:response)
    values = data.select do |d|
      country = d.dig(:league, :country)
      name = d.dig(:league, :name)
      FootballDivision.exists?(rapid_api_country: country, rapid_api_name: name)
    end

    goal_events = values.map { |f| f.dig(:fixture, :id) }.map do |f_id|
      resp = faraday.get("/v3/fixtures/events", fixture: f_id)
      resp.body.fetch(:response).select { |f| f.fetch(:type) == "Goal" }
    end
    values.zip(goal_events).each do |value, event_list|
      Rails.logger.debug "#{value} #{event_list}"

      home_team = find_or_create_team value.dig(:teams, :home, :name)
      away_team = find_or_create_team value.dig(:teams, :away, :name)
      homescore = value.dig(:score, :fulltime, :home)
      awayscore = value.dig(:score, :fulltime, :away)

      homehtscore = value.dig(:score, :halftime, :home)
      awayhtscore = value.dig(:score, :halftime, :away)

      kickoff = value.dig(:fixture, :date)

      division = FootballDivision.find_by!(rapid_api_country: value.dig(:league, :country), rapid_api_name: value.dig(:league, :name)).division

      match = division.find_match home_team, away_team, date

      if match.nil?
        logger.debug { "Creating #{date} #{home_team.name} v #{away_team.name} #{homescore}-#{awayscore}(#{homehtscore}-#{awayhtscore})" }
        match = division.matches.create! kickofftime: kickoff, venue: home_team, name: "#{home_team.name} v #{away_team.name}", type: "SoccerMatch"
      end
      unless homescore.blank? || awayscore.blank? || match.result
        match.create_result! homescore: homescore, awayscore: awayscore,
                             half_time_home_score: homehtscore, half_time_away_score: awayhtscore
      end

      event_list.each do |goal|
        goaltime = goal.dig(:time, :elapsed)
        match.scorers.create! goaltime: goaltime <= 45 ? (60 * goaltime) : 60 * (goaltime + 15),
                              owngoal: goal.fetch(:detail) == "OwnGoal",
                              penalty: goal.fetch(:detail) == "Penalty",
                              name: goal.dig(:player, :name),
                              team: goal.dig(:team, :name) == value.dig(:teams, :home, :name) ? home_team : away_team
      end
    end
  end

private

  def find_or_create_team(raw_name)
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

# frozen_string_literal: true

class RapidApiFixturesJob < RapidApiJob
  queue_priority PRIORITY_LOAD_FOOTBALL_DATA

  def perform(date)
    response = faraday.get("/v3/fixtures", date: date.to_s)
    # response = faraday.get("/v3/leagues", country: "England")
    data = response.body.fetch(:response)

    leagues = data.map { |d| d.fetch(:league) }
                  .reject { |c| UNLIKELY_COUNTRIES.include? c.fetch(:country) }
                  .map { |f| [f.fetch(:country), f.fetch(:name)] }
                  .uniq.sort_by { |cl| "#{cl.first} #{cl.last}" }.select do |item|
      logger.debug("Rapid API country [#{item.first}] League [#{item.last}]")
      FootballDivision.exists?(rapid_api_country: item.first, rapid_api_name: item.last)
    end
    values = data.select do |d|
      country = d.dig(:league, :country)
      name = d.dig(:league, :name)
      leagues.include? [country, name]
    end

    values.each do |value|
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

      RapidApiFixtureEventsJob.perform_later match, value.dig(:fixture, :id), value[:teams]
    end
  end

private

  UNLIKELY_COUNTRIES_A = %w[Andorra Albania Armenia Aruba Armenia Argentina Algeria Angola Azerbaidjan].freeze
  UNLIKELY_COUNTRIES_B = %w[Belarus Benin Botswana Boliva Bosnia Bulgaria Cameroon Chile Cuba Colombia Croatia].freeze
  UNLIKELY_COUNTRIES_E = %w[Ecuador Egypt Eswatini Estonia Ethopia Nigeria Gibraltar Ghana Guadeloupe Guatemala].freeze
  UNLIKELY_COUNTRIES_I = %w[Iran Russia Tajikistan Malawi India Indonesia Kazakhstan Kenya Kosovo Latvia].freeze
  UNLIKELY_COUNTRIES_M = %w[Mali Malaysia Macao Macendonia Panama Peru Slovakia Slovenia Sudan Surinam World].freeze
  UNLIKELY_COUNTRIES_W = %w[South-Korea Singapore Zambia].freeze
  UNLIKELY_COUNTRIES = UNLIKELY_COUNTRIES_A + UNLIKELY_COUNTRIES_E + UNLIKELY_COUNTRIES_B + UNLIKELY_COUNTRIES_I + UNLIKELY_COUNTRIES_M + UNLIKELY_COUNTRIES_W

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

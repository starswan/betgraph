# frozen_string_literal: true

class BbcSoccerScoresJob < ApplicationJob
  queue_as :default

  HOST = "https://push.api.bbci.co.uk"
  URL = "/batch"

  class NullEncoder
    class << self
      def encode(query)
        query.map { |k, v|
          "#{k}=#{v}"
        }.join("?")
      end

      def decode(query)
        query
      end
    end
  end

  def perform(date)
    faraday = Faraday.new(
      request: { params_encoder: NullEncoder },
      url: HOST,
    ) do |f|
      f.request :instrumentation
      f.response :raise_error
      f.response :json, parser_options: { symbolize_names: true }
    end

    param = { data: "bbc-morph-football-scores-match-list-data",
              endDate: date.to_s,
              startDate: date.to_s,
              todayDate: "2022-10-08",
              tournament: "full-priority-order",
              version: "2.4.6",
              withPlayerActions: "true" }
    t_param = param.map { |k, v| "/#{k}/#{v}" }.join
    timeout = 5

    response = faraday.get URL, t: t_param, timeout: timeout

    body = response.body.fetch(:payload).fetch(0).fetch(:body)
    body.fetch(:matchData).each do |md|
      slug = md.fetch(:tournamentMeta).fetch(:tournamentSlug)
      Rails.logger.debug "Division slug #{slug}"
      fd = FootballDivision.find_by(bbc_slug: slug)
      next if fd.blank?

      division = fd.division

      dates = md.fetch(:tournamentDatesWithEvents).values
      x = dates.fetch(0).fetch(0).fetch(:events)
      x.each do |event|
        home_team = find_or_create_team(event.dig(:homeTeam, :name, :full))
        away_team = find_or_create_team(event.dig(:awayTeam, :name, :full))
        homescore = event.dig(:homeTeam, :scores, :fullTime)
        homehtscore = event.dig(:homeTeam, :scores, :halfTime)
        awayhtscore = event.dig(:awayTeam, :scores, :halfTime)
        awayscore = event.dig(:awayTeam, :scores, :fullTime)
        kickoff = event.fetch(:startTime)

        home_scorers = event.dig(:homeTeam, :playerActions).select { |z| z.dig(:actions, 0, :type) == "goal" }
        away_scorers = event.dig(:awayTeam, :playerActions).select { |z| z.dig(:actions, 0, :type) == "goal" }

        match = division.find_match home_team, away_team, date

        if match.nil?
          logger.debug { "Creating #{date} #{home_team.name} v #{away_team.name} #{homescore}-#{awayscore}(#{homehtscore}-#{awayhtscore})" }
          match = division.matches.create! kickofftime: kickoff, venue: home_team, name: "#{home_team.name} v #{away_team.name}", type: "SoccerMatch"
        end
        unless homescore.blank? || awayscore.blank? || match.result
          match.create_result! homescore: homescore, awayscore: awayscore,
                               half_time_home_score: homehtscore, half_time_away_score: awayhtscore
        end
        create_scorers(match, home_scorers, home_team)
        create_scorers(match, away_scorers, away_team)

        # Rails.logger.debug "HomeTeam #{event.dig(:homeTeam, :name)}"
        # Rails.logger.debug "Home Goals #{event.dig(:homeTeam, :playerActions)}"
        # Rails.logger.debug "Home Scores #{event.dig(:homeTeam, :scores)}"
        # Rails.logger.debug "AwayTeam #{event.dig(:awayTeam, :name)}"
        # Rails.logger.debug "Away Goals #{event.dig(:awayTeam, :playerActions)}"
        # Rails.logger.debug "Away Scores #{event.dig(:awayTeam, :scores)}"
        # Rails.logger.debug "---------------------------------"
      end
    end
  end

private

  def create_scorers(match, scorers, team)
    scorers.each do |action|
      match.scorers.create! goaltime: 60 * action.dig(:actions, 0, :timeElapsed),
                            owngoal: action.dig(:actions, 0, :ownGoal),
                            penalty: action.dig(:actions, 0, :penalty),
                            name: action.dig(:name, :abbreviation),
                            team: team
    end
  end

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

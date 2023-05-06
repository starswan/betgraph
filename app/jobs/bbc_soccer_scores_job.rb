# frozen_string_literal: true

class BbcSoccerScoresJob < ApplicationJob
  queue_priority PRIORITY_LOAD_FOOTBALL_DATA

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
              todayDate: "2023-04-23",
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
      next unless division.active?

      dates = md.fetch(:tournamentDatesWithEvents).values
      x = dates.fetch(0).fetch(0).fetch(:events)
      x.each do |event|
        ProcessBbcScoresJob.perform_later division, date, event
      end
    end
  end

end

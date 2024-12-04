# frozen_string_literal: true

class BbcSoccerScoresJob < ApplicationJob
  queue_priority PRIORITY_LOAD_FOOTBALL_DATA

  HOST = "https://web-cdn.api.bbci.co.uk"
  URL = "/wc-poll-data/container/sport-data-scores-fixtures"

  def perform(date)
    faraday = Faraday.new(
      url: HOST,
    ) do |f|
      f.request :instrumentation
      f.response :raise_error
      f.response :json, parser_options: { symbolize_names: true }
    end

    params = { selectedEndDate: date.to_s,
               selectedStartDate: date.to_s,
               todayDate: "2024-12-01",
               urn: "urn:bbc:sportsdata:football:tournament-collection:collated" }

    response = faraday.get URL, params

    response.body.fetch(:eventGroups).each do |md|
      Rails.logger.debug "BBC Data #{md}"

      bbc_slug = md.fetch(:displayLabelOnwardJourneyPath)
      next if bbc_slug.nil?

      Rails.logger.debug "Division slug #{bbc_slug}"
      fd = FootballDivision.find_by(bbc_slug: bbc_slug.split("/")[3])
      next if fd.blank?

      division = fd.division
      next unless division.active?

      md.fetch(:secondaryGroups).each do |sg|
        sg.fetch(:events).each do |event|
          ProcessBbcScoresJob.perform_later division, event
        end
      end
    end
  end
end

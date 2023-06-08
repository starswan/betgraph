# frozen_string_literal: true

#
# $Id$
#
class LoadAllFootballDataJob < ApplicationJob
  # queue_priority :load_football_data
  queue_priority PRIORITY_LOAD_FOOTBALL_DATA

  def perform
    Season.online.where("startdate < ?", Time.zone.today).order(:startdate).each do |season|
      LoadFootballDataJob.perform_later((season.startdate + 9.months).to_s)
    end
  end
end

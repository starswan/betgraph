# frozen_string_literal: true

#
# $Id$
#
class LoadCurrentFootballDataJob < ApplicationJob
  queue_priority PRIORITY_LOAD_FOOTBALL_DATA

  def perform
    LoadFootballDataJob.perform_later Time.zone.today.to_s
  end
end

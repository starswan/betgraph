# frozen_string_literal: true

#
# $Id$
#
class LoadCurrentFootballDataJob < ApplicationJob
  # queue_priority :load_football_data
  queue_priority PRIORITY_LOAD_FOOTBALL_DATA

  def perform
    LoadFootballDataJob.perform_later Date.today.to_s
  end
end

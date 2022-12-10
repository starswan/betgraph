# frozen_string_literal: true

#
# $Id$
#
class MakeAllMatchesJob < ApplicationJob
  queue_priority PRIORITY_MAKE_MATCHES

  def perform(*_args)
    Sport.active.each do |sport|
      MakeMatchesJob.perform_later sport
    end
  end
end

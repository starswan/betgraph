# frozen_string_literal: true

#
# $Id$
#
class KeepEverythingAliveJob < ApplicationJob
  # queue_priority :keep_alive
  queue_priority PRIORITY_KEEP_ALIVE

  def perform
    10.times { KeepAliveJob.perform_later }
  end
end

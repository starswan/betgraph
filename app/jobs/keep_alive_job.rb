# frozen_string_literal: true

#
# $Id$
#
class KeepAliveJob < BetfairJob
  queue_priority PRIORITY_KEEP_ALIVE

  def perform
    bc.keepAlive
  end
end

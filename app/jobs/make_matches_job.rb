# frozen_string_literal: true

#
# $Id$
#
class MakeMatchesJob < BetfairJob
  queue_priority PRIORITY_MAKE_MATCHES

  def perform(sport)
    sport.competitions.active.each { |competition| MakeDivisionMatchesJob.perform_later(competition) }
  end
end

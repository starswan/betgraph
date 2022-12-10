# frozen_string_literal: true

#
# $Id$
#
class DestroyDeletedMatchesJob < ApplicationJob
  # queue_priority :destroy_object
  queue_priority PRIORITY_DESTROY_OBJECT

  def perform
    Match.only_deleted.each do |match|
      DestroyObjectJob.perform_later(match)
    end
    BetMarket.only_deleted.each do |match|
      DestroyObjectJob.perform_later(match)
    end
  end
end

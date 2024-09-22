# frozen_string_literal: true

#
# $Id$
#
class ApplicationJob < ActiveJob::Base
  queue_as :default

  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked

  # don't allow network errors to kill jobs
  retry_on SocketError
  retry_on Net::OpenTimeout
  retry_on Net::ReadTimeout

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError
  # Not worth retrying a badly-formed job
  discard_on ArgumentError

  OFFSET_PRI = 56_000

  PRIORITY_EXECUTE_TRADE = OFFSET_PRI + 10
  PRIORITY_CLOSE_DEAD_MARKETS = OFFSET_PRI + 15
  PRIORITY_LIVE_PRICES = OFFSET_PRI + 20
  # Runners for existing matches more important that new matches
  # and basket items also more important than new runners
  PRIORITY_MAKE_BASKET_ITEMS = OFFSET_PRI + 25
  PRIORITY_MAKE_RUNNERS = OFFSET_PRI + 30
  PRIORITY_REFRESH_SPORT_LIST = OFFSET_PRI + 35
  # this should be lower than most BetfairJob's - makeMenuPaths is an exception to this rule
  # and make matches, as otherwise old 'dead' objects prevent new ones being created
  PRIORITY_DESTROY_OBJECT = OFFSET_PRI + 40
  PRIORITY_MAKE_MATCHES = OFFSET_PRI + 45

  # Lower than lowest BetfairJob which is currently make menu paths
  PRIORITY_KEEP_ALIVE = OFFSET_PRI + 50

  # Load historic data higher than batch job so it gets throughput
  PRIORITY_LOAD_HISTORIC_DATA = OFFSET_PRI + 52
  PRIORITY_LOAD_FOOTBALL_DATA = OFFSET_PRI + 55
  # This don't involve connecting to the API, so lower tnan everything
  PRIORITY_INFER_GOAL_TIMES = OFFSET_PRI + 65
  PRIORITY_REMOVE_MARKETS_WITH_GAPS = OFFSET_PRI + 70

  include Backburner::Queue

  def destroy_object(object)
    DestroyObjectJob.perform_later object
  end
end

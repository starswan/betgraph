# frozen_string_literal: true

#
# $Id$
#
# require File.expand_path("../environment", __FILE__)
require "./config/boot"
require "./config/environment"

require "clockwork"
# MAKE_MARKETS_INTERVAL = 3600
# JOBS = {
#   'make.matches' => [ {}, { :ttr => MAKE_MARKETS_INTERVAL } ],
#   'capture.live.prices' => [ {}, { :pri => 5, :ttr => 1200 } ],
#   'trigger.live.prices' => [ {}, { :pri => 5, :ttr => 1200 } ],
#   'load.football.data' => [ { :date => Date.today }, {:ttr => 600} ],
#   'keep.alive' => [ {}, { :pri => 1 } ],
#   # Need to avoid capturing dead markets so higher priority than capture
#   'close.dead.markets' => [ {}, { :pri => 3 } ],
# }
#
class BetfairClockwork
  include Clockwork

  configure do |config|
    # config[:sleep_timeout] = 30.seconds
    # config[:logger] = Rails.logger if Rails.env.production?
    config[:logger] = if Rails.env.development?
                        Logger.new($stdout)
                      else
                        Rails.logger
                      end
    # @next_trigger = Time.zone.now
  end

  handler do |symbol|
    send(symbol)
  end

  class << self
    # def triggerliveprices
    #   now = Time.zone.now
    #   if now >= @next_trigger
    #     TriggerLivePricesJob.perform_later
    #     next_time = BetMarket.live.order(:time).first&.time || Time.zone.now + 2.hours
    #     gap = (next_time - now) / 2
    #     if gap > 0
    #       @next_trigger = now + gap
    #       Rails.logger.info "Clockwork: next live price check at #{@next_trigger}"
    #     end
    #   end
    # end

    def refreshsportlist
      RefreshSportListJob.perform_later
    end

    def makematches
      Sport.active.each { |sport| MakeMatchesJob.perform_later sport }
    end

    def loadfootballdata
      LoadCurrentFootballDataJob.perform_later
    end

    def closedead
      CloseDeadMarketsJob.perform_later
    end

    def keepalive
      KeepEverythingAliveJob.perform_later
    end

    def destroymatches
      DestroyDeletedMatchesJob.perform_later
      DeleteInactiveMarketsJob.perform_later
    end

    def infer_goal_times
      InferAllGoalTimesJob.perform_later
    end

    def remove_with_gaps
      RemoveMarketsWithGapsJob.perform_later
    end

    def load_bbc_data
      BbcSoccerScoresJob.perform_later(Time.zone.yesterday)
    end
  end

  # need to run this every day, as it triggers the creation of matches
  every 1.day, :refreshsportlist, at: "01:00"
  # Think its ok to run live prices on alice now as we have made it much quieter
  # every 1.minutes, :triggerliveprices unless Rails.env.production?
  # every 30.seconds, :triggerliveprices
  # This can take a long time to run on a Raspberry PI
  every 2.hours, :makematches
  # every 30.minutes, :makematches
  # Don't try to load football data in June/July because there isn't any to get
  # but do run it as late in the day as possible to pick up the results
  # (There is a tiny bit in July, but that's picked up on Aug 1st anyway)
  every 24.hours, :loadfootballdata, at: "23:00", unless: ->(t) { t.month.in? [6, 7] }

  # load yesterday's scores data from BBC website
  every 24.hours, :load_bbc_data
  # every 24.hours, :loadfootballdata, if: ->(t) { t.month <= 5 || t.month >= 8 }
  every 15.minutes, :closedead
  every 24.hours, :destroymatches, at: "05:00"
  every 3.hours, :keepalive
  # don't want this after deployment
  every 1.week, :infer_goal_times, at: "02:00"
  # don't want this after deployment
  every 1.week, :remove_with_gaps, at: "03:00"
end

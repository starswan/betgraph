# frozen_string_literal: true

#
# $Id$
#
# need to run this every day, as it triggers the creation of matches
# every 1.day, :refreshsportlist, at: "01:00"
every :day, at: ["01:00"] do
  runner "RefreshSportListJob.perform_later"
end

# every 2.hours, :makematches
every 2.hours do
  runner "Sport.active.each { |sport| MakeMatchesJob.perform_later(sport) }"
end
# Don't try to load football data in June/July because there isn't any to get
# but do run it as late in the day as possible to pick up the results
# (There is a tiny bit in July, but that's picked up on Aug 1st anyway)
# every 24.hours, :loadfootballdata, at: "23:00", unless: ->(t) { t.month.in? [6, 7] }
every 24.hours, at: ["23:00"] do
  runner "LoadCurrentFootballDataJob.perform_later"
end

# load yesterday's scores data from BBC website
# every 24.hours, :load_bbc_data
every :day do
  runner "BbcSoccerScoresJob.perform_later(Time.zone.yesterday)"
end

# every 15.minutes, :closedead
every 15.minutes do
  runner "CloseDeadMarketsJob.perform_later"
end

# every 24.hours, :destroymatches
every :day do
  runner "DestroyDeletedMatchesJob.perform_later"
  runner "DeleteInactiveMarketsJob.perform_later"
end

# every 3.hours, :keepalive
every 3.hours do
  runner "KeepEverythingAliveJob.perform_later"
end

# don't want this after every deployment
# every 1.week, :infer_goal_times, at: "02:00"
every 1.week, at: ["02:00"] do
  runner "InferAllGoalTimesJob.perform_later"
end

# don't want this after every deployment
# every 1.week, :remove_with_gaps, at: "03:00"
every 1.week, at: ["03:00"] do
  runner "RemoveMarketsWithGapsJob.perform_later"
end

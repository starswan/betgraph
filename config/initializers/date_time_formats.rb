# frozen_string_literal: true

#
# $Id$
#
Time::DATE_FORMATS.merge!(
  kickoff: "%a %d-%b-%Y %H:%M",
  precise: "%a %d-%b-%Y %H:%M:%S",
  time_with_secs: "%H:%M:%S",
  time_without_secs: "%H:%M",
  season: "%d-%b %y",
)

Date::DATE_FORMATS.merge!(
  season: "%a %-d %b"
)

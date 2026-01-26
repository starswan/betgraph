# frozen_string_literal: true

#
# $Id$
#
# Job needing access to Betfair API

class BetfairJob < ApplicationJob
  # this change appears to have been detrimental
  # retry_on Curl::Err::TimeoutError

  def bc
    @@bc ||= BetfairLogin.new logger
  end
end

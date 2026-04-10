# frozen_string_literal: true

#
# $Id$
#
# Job needing access to Betfair API

class BetfairJob < ApplicationJob
  # this change appears to have been detrimental
  # retry_on Curl::Err::TimeoutError
  retry_on HTTPClient::ConnectTimeoutError, wait: ->(executions) { executions**2 }, attempts: 10
  retry_on HTTPClient::ReceiveTimeoutError, wait: ->(executions) { executions**2 }, attempts: 10

  def bc
    @@bc ||= BetfairLogin.new logger
  end
end

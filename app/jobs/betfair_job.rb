# frozen_string_literal: true

#
# $Id$
#
# Job needing access to Betfair API

class BetfairJob < ApplicationJob
  def bc
    @@bc ||= BetfairLogin.new logger
  end
end

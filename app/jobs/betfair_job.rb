# frozen_string_literal: true

#
# $Id$
#
# Job needing access to Betfair API

require "rails_client"

class BetfairJob < ApplicationJob
  def bc
    @@bc ||= BetfairLogin.new logger
  end

  def railsclient
    @@railsclient ||= RailsClient.new(url, logger)
  end

  def url
    @@url ||= "http://#{Settings.webservice}"
  end

  def self.railsclient=(client)
    @@railsclient = client
  end
end

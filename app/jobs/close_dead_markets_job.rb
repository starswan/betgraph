# frozen_string_literal: true

#
# $Id$
#
class CloseDeadMarketsJob < ApplicationJob
  # queue_priority :close_dead_markets
  queue_priority PRIORITY_CLOSE_DEAD_MARKETS

  def perform
    BetMarket.where("time <= ? and status != ?", Time.now, BetMarket::CLOSED).includes(:match).each do |market|
      market.update!(status: BetMarket::CLOSED) if Time.now > market.match.endtime
    end
  end
end

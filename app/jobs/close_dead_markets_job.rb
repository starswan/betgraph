# frozen_string_literal: true

#
# $Id$
#
class CloseDeadMarketsJob < ApplicationJob
  queue_priority PRIORITY_CLOSE_DEAD_MARKETS

  def perform
    BetMarket.kept
             .not_closed
             .includes(:match)
             .select { |bm| Time.now > bm.match.endtime }
             .each { |market| market.assign_attributes(status: BetMarket::CLOSED).tap { |m| m.save!(validate: false) } }
  end
end

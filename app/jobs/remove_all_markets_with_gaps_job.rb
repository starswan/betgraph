# frozen_string_literal: true

class RemoveAllMarketsWithGapsJob < ApplicationJob
  queue_priority PRIORITY_REMOVE_MARKETS_WITH_GAPS

  def perform
    # Delete closed markets if there are any large gaps in the price trail.
    BetMarket.closed.api_priced.where("updated_at >= ?", Time.zone.now - 2.weeks)
      .where.not(prices_count: 0).find_in_batches { |batch| RemoveMarketWithGapJob.perform_later(batch.map(&:id)) }
  end
end

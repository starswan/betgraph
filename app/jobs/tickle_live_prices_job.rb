# frozen_string_literal: true

class TickleLivePricesJob < ApplicationJob
  queue_priority PRIORITY_LIVE_PRICES

  def perform
    matches = BetMarket.activelive.group_by(&:match).keys

    if matches.any?
      matches.each { |match| CaptureMatchPricesJob.perform_later match }
      TickleLivePricesJob.set(wait: 45.seconds).perform_later
    else
      first_market = BetMarket.live.order(:time).first
      if first_market
        now = Time.zone.now
        next_time = first_market.time || Time.zone.now + 1.day
        gap = (next_time - now) / 2
        if gap.positive?
          TickleLivePricesJob.set(wait: gap.seconds).perform_later
        end
      end
    end
  end
end

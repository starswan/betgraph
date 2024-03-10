class TickleLivePricesJob < ApplicationJob
  queue_priority PRIORITY_LIVE_PRICES

  def perform
    activelive = BetMarket.activelive

    if activelive.any?
      activelive.group_by(&:match).each_key { |match| CaptureMatchPricesJob.perform_later match }
      TickleLivePricesJob.set(wait: 45.seconds).perform_later
    else
      lives = BetMarket.live.order(:time)
      if lives.any?
        now = Time.zone.now
        gaps = lives.map { |live_bm| (live_bm - now) / 2 }
        positive_gaps = gaps.select(&:positive?)
        if gaps.any?
          TickleLivePricesJob.set(wait: positive_gaps.first.seconds).perform_later
        else
          logger.debug("TickleLivePricesJob stopped for negative #{gaps.last}")
        end
      else
        logger.debug("TickleLivePricesJob stopped due to no live markets")
      end
    end
  end
end

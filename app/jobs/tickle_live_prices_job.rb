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
        next_time = lives.first.time
        gap = (next_time - now) / 2
        if gap.positive?
          TickleLivePricesJob.set(wait: gap.seconds).perform_later
        else
          logger.info("TickleLivePricesJob stopped for negative #{gap}")
        end
      end
    end
  end
end

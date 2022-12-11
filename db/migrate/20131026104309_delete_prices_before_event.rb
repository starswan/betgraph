# frozen_string_literal: true

#
# $Id$
#
class DeletePricesBeforeEvent < ActiveRecord::Migration[4.2]
  def up
    count = BetfairEvent.count
    BetfairEvent.find_each.with_index do |event, index|
      BetfairEvent.transaction do
        say_with_time "BetfairEvent #{100 * index / count}% #{index}/#{count} #{event.inspect}" do
          tidy_event event
        end
      end
    end
  end

  def down; end

private

  def tidy_event(event)
    event.bet_markets.each do |market|
      times = market.market_price_times.where("time < ?", market.time - 15.minutes)
      next if times.count == 0

      say_with_time "Deleting #{market.name} #{times.count} Prices from #{times[0].time} to #{times[-1].time}" do
        times.each(&:destroy)
      end
    end
  end
end

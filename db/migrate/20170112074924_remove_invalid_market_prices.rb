# frozen_string_literal: true

#
# $Id$
#
class RemoveInvalidMarketPrices < ActiveRecord::Migration[4.2]
  def up
    mp = MarketPrice.where(back1price: nil, lay1price: nil)
    count = mp.count
    index = 0
    mp.find_in_batches do |batch|
      say_with_time "destroying MarketPrice #{index}/#{count} #{index * 100.0 / count}%" do
        batch.each { |item| item.destroy }
        index += batch.size
      end
    end
  end
end

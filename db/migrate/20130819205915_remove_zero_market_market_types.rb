# frozen_string_literal: true

#
# $Id$
#
class RemoveZeroMarketMarketTypes < ActiveRecord::Migration[4.2]
  def up
    Sport.all.find_each do |sport|
      sport.betfair_market_types.select { |bmt| bmt.bet_markets.count.zero? }.each do |market_type|
        say_with_time "#{sport.name} #{market_type.name}" do
          market_type.destroy
        end
      end
    end
  end

  def down; end
end

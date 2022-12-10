# frozen_string_literal: true

#
# $Id$
#
class InactiveMarketTypes < ActiveRecord::Migration[4.2]
  def change
    BetfairMarketType.includes(:bet_markets).where(active: false).each do |bmt|
      bmt.bet_markets.select(&:active).each do |market|
        market.active = false
        market.save!
      end
    end
  end
end

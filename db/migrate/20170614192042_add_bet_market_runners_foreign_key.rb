# frozen_string_literal: true

#
# $Id$
#
class AddBetMarketRunnersForeignKey < ActiveRecord::Migration[4.2]
  def change
    MarketRunner.includes(:bet_market).find_each do |mr|
      mr.destroy if mr.bet_market.nil?
    end
    add_foreign_key :market_runners, :bet_markets
  end
end

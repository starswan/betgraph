# frozen_string_literal: true

#
# $Id$
#
class BetMarketNullWinnerCount < ActiveRecord::Migration[5.2]
  def change
    change_column_null :bet_markets, :number_of_winners, true
  end
end

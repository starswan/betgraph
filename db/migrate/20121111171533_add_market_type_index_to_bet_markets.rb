# frozen_string_literal: true

#
# $Id$
#
class AddMarketTypeIndexToBetMarkets < ActiveRecord::Migration[4.2]
  def change
    add_index :bet_markets, :betfair_market_type_id
    add_index :betfair_market_types, :sport_id
  end
end

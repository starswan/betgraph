# frozen_string_literal: true

#
# $Id$
#
class AddStatusToMarketPrices < ActiveRecord::Migration[5.1]
  def change
    change_table :market_prices do |t|
      t.string :status, limit: 20, null: false, default: "ACTIVE"
    end
  end
end

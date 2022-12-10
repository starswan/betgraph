# frozen_string_literal: true

#
# $Id$
#
class AddMarketRunnerIndexToBasketItems < ActiveRecord::Migration[4.2]
  def change
    add_index :basket_items, :market_runner_id
  end
end

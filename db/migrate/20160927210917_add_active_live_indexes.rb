# frozen_string_literal: true

#
# $Id$
#
class AddActiveLiveIndexes < ActiveRecord::Migration[4.2]
  def change
    add_index :bet_markets, :live
    add_index :matches, :live_priced
  end
end

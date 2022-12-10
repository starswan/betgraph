# frozen_string_literal: true

#
# $Id$
#
class RemoveMenuPathFromBetMarket < ActiveRecord::Migration[5.1]
  BATCH_SIZE = 1000

  def up
    remove_foreign_key :bet_markets, :menu_paths

    remove_column :bet_markets, :menu_path_name
    remove_column :bet_markets, :menu_path_id
  end

  def down
    add_column :bet_markets, :menu_path_id, :integer
    add_column :bet_markets, :menu_path_name, :string

    index, count = 0, BetMarket.count
    BetMarket.find_in_batches(batch_size: BATCH_SIZE) do |batch|
      say_with_time("updating #{index}/#{count}") do
        batch.each do |bm|
          menu_path = bm.match.division.menu_paths.active.first
          bm.menu_path_id = menu_path.id
          bm.menu_path_name = menu_path.name
          bm.save!
        end
        index += BATCH_SIZE
      end
    end

    change_column_null :bet_markets, :menu_path_id, false
    change_column_null :bet_markets, :menu_path_name, false

    add_foreign_key :bet_markets, :menu_paths
  end
end

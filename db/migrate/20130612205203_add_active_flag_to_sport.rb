# frozen_string_literal: true

#
# $Id$
#
class AddActiveFlagToSport < ActiveRecord::Migration[4.2]
  def up
    change_table :sports do |t|
      t.boolean :active, default: false, null: false
    end
    change_column :sports, :betfair_sports_id, :integer, null: false
    remove_column :sports, :menu_path_id
    change_table :menu_paths do |t|
      t.integer :sport_id, null: false
    end
    count = MenuPath.count
    root = MenuPath.findByName([])
    MenuPath.all.each_with_index do |mp, index|
      say_with_time "#{mp.name.inspect} #{index}/#{count}" do
        MenuPath.transaction do
          sport = Sport.find_by name: mp.name[0]
          mp.sport = sport
          mp.parent_path = nil if mp.parent_path == root
          mp.save!
        end
      end
    end
    root.destroy!
  end

  def down
    remove_column :menu_paths, :sport_id
    root = MenuPath.create! name: [], active: false, depth: 1

    change_table :sports do |t|
      t.integer :menu_path_id, null: false
    end
    Sport.all.find_each do |sport|
      mp = MenuPath.findByName [sport.name]
      sport.menu_path = mp
      mp.parent_path = root
      mp.save!
      sport.save!
    end
    change_column :sports, :betfair_sports_id, :integer, null: true
    remove_column :sports, :active
  end
end

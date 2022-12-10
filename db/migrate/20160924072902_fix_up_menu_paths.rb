# frozen_string_literal: true

#
# $Id$
#
class FixUpMenuPaths < ActiveRecord::Migration[4.2]
  def up
    MenuPath.transaction do
      MenuPath.where.not(division: nil).each do |menu_path|
        menu_path.menu_paths.each do |mp|
          fix_menu_path menu_path, mp
        end
      end
      MenuPath.find_each do |mp|
        process_menu_path(mp) if check_menu_path(mp)
      end
      MenuPath.all
          .select { |mp| MenuPath.findAllByName(mp.name).count > 1 }
          .map { |x| MenuPath.findAllByName(x.name) }.each do |dup|
        say_with_time "doing #{dup.inspect}" do
          next if dup.size < 2

          dup[1].bet_markets.each do |bm|
            dup[0].bet_markets << bm
          end
          dup[1].children.each do |bm|
            dup[0].children << bm
          end
          dup[0].reload
          dup[1].reload
          dup[1].destroy if (dup[1].children.count == 0) && (dup[1].bet_markets.count == 0)
        end
      end
    end
    remove_index :menu_paths, :name
    add_index :menu_paths, :name, unique: true
  end

private

  def process_menu_path(mp)
    new_name = mp.name.map { |ns| ns.strip }
    if mp.name != new_name
      say_with_time "updating #{mp.id} #{mp.name.inspect} to #{new_name.inspect}" do
        existing = MenuPath.findByName new_name
        if existing
          existing.menu_paths.each do |existing_child|
            mp.menu_paths << existing_child
          end
          # existing.reload
          # existing.destroy if existing.menu_paths.count == 0
        end
        mp.name = new_name
        mp.sport = Sport.find_by(name: mp.name[0]) unless mp.sport
        mp.save!
      end
    end
  end

  # A few MenuPaths have crap names - need to kill them off before processing
  def check_menu_path(menu_path)
    begin
      menu_path.name
      true
    rescue StandardError
      menu_path.destroy
      false
    end
  end

  def fix_menu_path(parent, menu_path)
    if parent.depth > 20
      parent.depth = 19
      parent.active = true
      parent.activeChildren = true
      parent.activeGrandChildren = true
      parent.save!
    end
    if parent.division != menu_path.division
      menu_path.division = parent.division
      menu_path.depth = parent.depth - 1 if parent.depth > 0
      menu_path.active = parent.activeChildren
      menu_path.activeChildren = parent.activeGrandChildren
      menu_path.save!
    end
    menu_path.menu_paths.each do |child|
      fix_menu_path(menu_path, child)
    end
  end
end

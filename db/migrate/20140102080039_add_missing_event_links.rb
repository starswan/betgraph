# frozen_string_literal: true

#
# $Id$
#
class AddMissingEventLinks < ActiveRecord::Migration[4.2]
  BATCH_SIZE = 2000
  def up
    change_column :matches, :hometeam_id, :integer, null: true
    change_column :matches, :awayteam_id, :integer, null: true
    count = BetfairEvent.count
    index = 0
    BetfairEvent.find_in_batches(batch_size: BATCH_SIZE) do |event_batch|
      say_with_time "#{self} #{index}/#{count}" do
        event_batch.reject(&:match).each { |event| handle_event event }
      end
      index += BATCH_SIZE
    end
  end

  def down
    change_column :matches, :awayteam_id, :integer, null: false
    change_column :matches, :hometeam_id, :integer, null: false
  end

private

  def destroy_event(event, why)
    say_with_time "#{why} Destroying #{event.sport.name} #{event.menu_path.name.inspect} #{event.inspect}" do
      event.destroy
    end
  end

  def handle_event(event)
    name = event.description
    vs = name.index(" v ")
    if vs
      hometeamstr, awayteamstr = name[0, vs], name[vs + 3, name.size - 1]
    else
      vs = name.index(" @ ")
      awayteamstr, hometeamstr = name[0, vs], name[vs + 3, name.size - 1] if vs
    end
    return destroy_event(event, "Frame") if name == "Frame Betting"
    return destroy_event(event, "Fixtures") if name.start_with? "Fixtures"
    return destroy_event(event, "Set") if name.start_with? "Set"
    return destroy_event(event, "Group") if name.start_with? "Group"
    return destroy_event(event, "Specials") if name.end_with? "Specials"
    return destroy_event(event, "Innings") if name.end_with? "Innings"
    return destroy_event(event, "Day") if name.start_with? "Day "

    matches = []
    if vs
      hometeam = find_team(event.sport, hometeamstr)
      awayteam = find_team(event.sport, awayteamstr)
      matches = Match.where("kickofftime > ? and kickofftime < ? and hometeam_id = ? and awayteam_id = ?", event.starttime - 1.day, event.starttime + 1.day, hometeam, awayteam)
    end
    if matches.count == 0
      menu_path = event.menu_path
      return destroy_event(event, "No Menu Path") if menu_path.nil?

      while !menu_path.division
        menu_path = menu_path.parent_path
        return destroy_event(event, "Ran out of Menu Paths") unless menu_path
      end
      # say_with_time "creating match for #{event.inspect} #{event.sport.match_type}" do
      match = Module.const_get(event.sport.match_type).create!(division: menu_path.division,
                                                               kickofftime: event.starttime,
                                                               hometeam: hometeam,
                                                               awayteam: awayteam)
      matches = [match]
      # end
    end
    matches.each do |m|
      # say_with_time "#{name} match #{match.inspect}" do
      event.match = m
      event.save!
      # end
    end
  end

  def find_team(sport, name)
    teamname = TeamName.find_by(name: name)
    unless teamname
      team = sport.teams.new name: name
      team.save!
      teamname = TeamName.find_by(name: name)
    end
    teamname.team
  end
end

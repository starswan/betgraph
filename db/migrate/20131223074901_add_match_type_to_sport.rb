# frozen_string_literal: true

#
# $Id$
#
class AddMatchTypeToSport < ActiveRecord::Migration[4.2]
  def up
    change_table :sports do |t|
      t.string :match_type, length: 30, null: false
    end
    Sport.all.find_each do |sport|
      sport.match_type = "#{sport.name}Match"
      sport.save!
    end
    motorsport = Sport.find_by(name: "Motor Sport")
    motorsport.match_type = "MotorRace"
    motorsport.save!
  end

  def down
    remove_column :sports, :match_type
  end
end

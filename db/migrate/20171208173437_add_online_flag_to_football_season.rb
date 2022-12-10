# frozen_string_literal: true

#
# $Id$
#
class AddOnlineFlagToFootballSeason < ActiveRecord::Migration[4.2]
  def change
    change_table :football_seasons do |t|
      t.boolean :online, default: true
    end
    remove_column :football_seasons, :soccerbasenumber
  end
end

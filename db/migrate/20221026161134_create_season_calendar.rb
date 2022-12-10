# frozen_string_literal: true

class CreateSeasonCalendar < ActiveRecord::Migration[6.0]
  def change
    create_table :calendars do |t|
      t.references :sport
      t.string :name
    end
    rename_table :football_seasons, :seasons
    rename_column :matches, :football_season_id, :season_id
    change_table :seasons do |t|
      t.references :calendar
    end
    change_table :divisions do |t|
      t.references :calendar
    end
  end
end

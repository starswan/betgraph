# frozen_string_literal: true

#
# $Id$
#
class CreateFootballMatches < ActiveRecord::Migration[4.2]
  def change
    create_table :football_matches do |t|
      t.integer :football_season_id, null: false
      t.integer :match_id, null: false

      t.timestamps
    end
  end
end

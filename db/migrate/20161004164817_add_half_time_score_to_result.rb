# frozen_string_literal: true

#
# $Id$
#
class AddHalfTimeScoreToResult < ActiveRecord::Migration[4.2]
  def change
    change_table :results do |t|
      t.integer :half_time_home_score
      t.integer :half_time_away_score
    end
  end
end

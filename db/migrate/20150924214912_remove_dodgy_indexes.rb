# frozen_string_literal: true

#
# $Id$
#
class RemoveDodgyIndexes < ActiveRecord::Migration[4.2]
  def change
    remove_index "matches", columns: %w[division_id kickofftime], name: "index_matches_on_division_id_and_awayteam_id_and_kickofftime"
    remove_index "matches", columns: %w[division_id kickofftime], name: "index_matches_on_division_id_and_hometeam_id_and_kickofftime"
    remove_index "matches", columns: %w[kickofftime], name: "index_matches_on_kickofftime_and_hometeam_id_and_awayteam_id"
  end
end

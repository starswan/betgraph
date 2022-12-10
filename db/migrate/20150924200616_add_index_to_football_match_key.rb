# frozen_string_literal: true

#
# $Id$
#
class AddIndexToFootballMatchKey < ActiveRecord::Migration[4.2]
  def change
    add_index :football_matches, :match_id
  end
end

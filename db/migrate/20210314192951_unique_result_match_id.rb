# frozen_string_literal: true

#
# $Id$
#
class UniqueResultMatchId < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :results, :matches
    remove_index :results, :match_id
    add_index :results, :match_id, unique: true
    add_foreign_key :results, :matches
  end
end

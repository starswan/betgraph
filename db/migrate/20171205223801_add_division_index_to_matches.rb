# frozen_string_literal: true

#
# $Id$
#
class AddDivisionIndexToMatches < ActiveRecord::Migration[4.2]
  def change
    add_index :matches, :division_id
  end
end

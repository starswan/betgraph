# frozen_string_literal: true

#
# $Id$
#
class AddIndexToMenuPathDepth < ActiveRecord::Migration[4.2]
  def change
    add_index :menu_paths, :depth
  end
end

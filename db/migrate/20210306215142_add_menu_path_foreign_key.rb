# frozen_string_literal: true

#
# $Id$
#
class AddMenuPathForeignKey < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :menu_paths, :menu_paths, column: :parent_path_id
  end
end

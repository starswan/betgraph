# frozen_string_literal: true

#
# $Id$
#
class RemoveSpuriousMatchColumn < ActiveRecord::Migration[4.2]
  def up
    remove_column :matches, :integer
  end

  def down
    add_column :matches, :integer, :integer, null: false, default: 0
  end
end

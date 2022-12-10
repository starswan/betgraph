# frozen_string_literal: true

#
# $Id$
#
class AddDeletedAtToMatch < ActiveRecord::Migration[5.1]
  def change
    add_column :matches, :deleted_at, :datetime
    add_index :matches, :deleted_at
    remove_column :matches, :deleted
  end
end

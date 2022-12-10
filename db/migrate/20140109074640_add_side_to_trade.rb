# frozen_string_literal: true

#
# $Id$
#
class AddSideToTrade < ActiveRecord::Migration[4.2]
  def change
    add_column :trades, :side, :string, limit: 1, null: false
    rename_column :trades, :quantity, :size
  end
end

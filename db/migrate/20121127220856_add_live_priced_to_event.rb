# frozen_string_literal: true

#
# $Id$
#
class AddLivePricedToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :live_priced, :boolean, null: false, default: false
  end
end

# frozen_string_literal: true

#
# $Id$
#
class RenameEventToBetfairEvent < ActiveRecord::Migration[4.2]
  def change
    rename_table :events, :betfair_events
    rename_column :sports, :events_count, :betfair_events_count
    rename_column :bet_markets, :event_id, :betfair_event_id
    rename_column :baskets, :event_id, :betfair_event_id
  end

  # def down
  #  rename_column :baskets, :betfair_event_id, :event_id
  #  rename_column :bet_markets, :betfair_event_id, :event_id
  #  rename_column :sports, :betfair_events_count, :events_count
  #  rename_table :betfair_events, :events
  # end
end

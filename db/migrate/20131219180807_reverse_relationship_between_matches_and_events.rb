# frozen_string_literal: true

#
# $Id$
#
class ReverseRelationshipBetweenMatchesAndEvents < ActiveRecord::Migration[4.2]
  BATCHSIZE = 1000

  def up
    change_table :betfair_events do |t|
      t.integer :match_id, null: false
    end

    matches = Match.where("event_id is not null").order(:kickofftime)
    count = matches.count
    index = 0
    matches.find_in_batches(batch_size: BATCHSIZE) do |match_group|
      say_with_time "Match #{match_group.first.inspect} #{index}/#{count}" do
        match_group.each do |match|
          event = BetfairEvent.find match.event_id
          event.match_id = match.id
          event.save!
        end
      end
      index += BATCHSIZE
    end

    remove_foreign_key :matches, :events
    remove_column :matches, :event_id
    Match.reset_column_information
    Match.connection.schema_cache.clear!
  end

  def down
    change_table :matches do |t|
      t.integer :event_id
    end

    count = Match.count
    Match.all.each_with_index do |match, index|
      say_with_time "Event #{index}/#{count} #{match.inspect}" do
        match.event_id = match.event.id
        match.save!
      end
    end

    add_foreign_key :matches, :betfair_events, column: :event_id
    remove_column :betfair_events, :match_id
  end
end

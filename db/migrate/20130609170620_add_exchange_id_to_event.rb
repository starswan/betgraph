# frozen_string_literal: true

#
# $Id$
#
class AddExchangeIdToEvent < ActiveRecord::Migration[4.2]
  class Event < ApplicationRecord
  end
  def up
    change_table :events do |t|
      t.integer :exchange_id, null: false
    end
    count = Event.count
    Event.transaction do
      Event.all.each_with_index do |event, index|
        say_with_time "Event #{event.description} #{index}/#{count}" do
          event.exchange_id = 1
          event.save!
        end
      end
    end
  end

  def down
    remove_column :events, :exchange_id
  end
end

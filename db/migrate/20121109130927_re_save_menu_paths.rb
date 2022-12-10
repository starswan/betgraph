# frozen_string_literal: true

#
# $Id$
#
class ReSaveMenuPaths < ActiveRecord::Migration[4.2]
  class Event < ApplicationRecord
  end

  def up
    count = MenuPath.count
    MenuPath.all.each_with_index do |mp, index|
      say_with_time "#{index}/#{count} #{mp.name.inspect}" do
        mp.save!
      end
    end
    count = Event.count
    Event.transaction do
      Event.all.each_with_index do |e, index|
        say_with_time "#{index}/#{count} #{e.inspect}" do
          e.save!
        end
      end
    end
  end

  def down; end
end

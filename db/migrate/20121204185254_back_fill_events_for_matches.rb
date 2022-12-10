# frozen_string_literal: true

#
# $Id$
#
class BackFillEventsForMatches < ActiveRecord::Migration[4.2]
  class Event < ApplicationRecord
  end

  def self.up
    return if Event.count == 0

    query = Match.all(include: :event, conditions: ["kickofftime >= ?", Event.first.starttime]).reject { |m| m.event }
    count = query.count
    query.each_with_index do |match, index|
      say_with_time "Match #{index}/#{count}" do
        events = []
        match.hometeam.team_names.each do |hometeam|
          match.awayteam.team_names.each do |awayteam|
            events << Event.find_all_by_description("#{hometeam.name} v #{awayteam.name}")
          end
        end
        e = events.flatten.select { |ev| (ev.starttime.year == match.kickofftime.year) && (ev.starttime.month == match.kickofftime.month) && (ev.starttime.day == match.kickofftime.day) }

        if e.size == 1
          say_with_time "Event #{e[0].inspect} Match #{match.inspect}" do
            match.event = e[0]
            match.kickofftime = e[0].starttime
            match.save!
          end
        end
      end
    end
  end

  def self.down; end
end

# frozen_string_literal: true

#
# $Id$
#
class AddFootballMatches < ActiveRecord::Migration[4.2]
  def up
    index, count = 0, SoccerMatch.count
    SoccerMatch.find_in_batches do |group|
      say_with_time "SoccerMatch #{index}/#{count}" do
        SoccerMatch.transaction do
          group.each(&:add_football_match)
        end
      end
      index += group.size
    end
  end

  def down
    FootballMatch.delete_all
  end
end

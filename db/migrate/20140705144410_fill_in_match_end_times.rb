# frozen_string_literal: true

#
# $Id$
#
class FillInMatchEndTimes < ActiveRecord::Migration[4.2]
  def up
    index, count = 0, Match.count
    Match.find_in_batches(include: :division) do |group|
      say_with_time "Match #{index}/#{count}" do
        Match.transaction do
          group.each do |match|
            match.endtime = match.kickofftime + match.division.sport.expiry_time_in_minutes.minutes unless match.endtime
            match.save!
          end
        end
        index += group.size
      end
    end
  end

  def down; end
end

# frozen_string_literal: true

#
# $Id$
#
class RemoveFootballMatchesTable < ActiveRecord::Migration[4.2]
  class Event < ApplicationRecord
  end

  class Match < ApplicationRecord
    #    attr_accessible :division, :hometeam, :awayteam, :kickofftime, :event

    belongs_to :event
    belongs_to :hometeam, class_name: "Team", foreign_key: :hometeam_id
    belongs_to :awayteam, class_name: "Team", foreign_key: :awayteam_id
    belongs_to :division
  end

  class SoccerMatch < ApplicationRecord
    #    attr_accessible :division, :hometeam, :awayteam, :kickofftime, :event, :half_time_duration, :type, :actual_start_time

    self.table_name = :matches

    belongs_to :event
    belongs_to :hometeam, class_name: "Team", foreign_key: :hometeam_id
    belongs_to :awayteam, class_name: "Team", foreign_key: :awayteam_id
    belongs_to :division
  end

  class FootballMatch < ApplicationRecord
    #    attr_accessible :match, :football_season
    #    attr_accessible :half_time_duration, :actual_start_time

    belongs_to :match
    belongs_to :football_season

    def name
      match.hometeam.teamname + " v " + match.awayteam.teamname
    end
  end

  def find_each_with_index(klazz)
    index = 0
    klazz.find_each do |item|
      yield item, index
      index = index + 1
    end
  end

  def up
    change_table :matches do |t|
      t.datetime :actual_start_time
      t.integer  :half_time_duration, default: 900
      t.string   :type, null: false
    end
    count = FootballMatch.count
    find_each_with_index(FootballMatch) do |fm, index|
      say_with_time "#{fm.name} #{index}/#{count}" do
        SoccerMatch.transaction do
          fm.match.destroy
          SoccerMatch.create! half_time_duration: fm.half_time_duration,
                              actual_start_time: fm.actual_start_time,
                              hometeam: fm.match.hometeam,
                              awayteam: fm.match.awayteam,
                              division: fm.match.division,
                              event: fm.match.event,
                              kickofftime: fm.match.kickofftime,
                              type: "SoccerMatch"
        end
      end
    end
    count = Match.count
    find_each_with_index(Match) do |match, index|
      next if SoccerMatch.exists? match.id
      next unless match.division.sport.name == "Soccer"

      say_with_time "#{match.hometeam.teamname} v #{match.awayteam.teamname} #{index}/#{count}" do
        SoccerMatch.transaction do
          match.destroy
          SoccerMatch.create! hometeam: match.hometeam,
                              awayteam: match.awayteam,
                              division: match.division,
                              event: match.event,
                              kickofftime: match.kickofftime,
                              type: "SoccerMatch"
        end
      end
    end
    drop_table :football_matches
  end

  def down
    create_table "football_matches", force: true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "actual_start_time"
      t.integer  "half_time_duration", default: 900
      t.integer  "football_season_id",                  null: false
      t.integer  "match_id",                            null: false
    end
    add_index "football_matches", ["football_season_id"], name: "index_football_matches_on_football_season_id"
    add_index "football_matches", ["match_id"], name: "index_football_matches_on_match_id"

    count = SoccerMatch.count
    find_each_with_index(SoccerMatch) do |sm, index|
      say_with_time "#{sm.hometeam.teamname} v #{sm.awayteam.teamname} #{index}/#{count}" do
        season = FootballSeason.first(
          conditions: ["? < startdate and startdate < ?", sm.kickofftime - 1.year, sm.kickofftime],
          order: :startdate,
        )

        FootballMatch.create! half_time_duration: sm.half_time_duration,
                              actual_start_time: sm.actual_start_time,
                              match: sm,
                              football_season: season
      end
    end

    remove_column :matches, :actual_start_time
    remove_column :matches, :half_time_duration
    remove_column :matches, :type
  end
end

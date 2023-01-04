# frozen_string_literal: true

#
# $Id$
#
class MoveTeamsToOwnTable < ActiveRecord::Migration[4.2]
  BATCH_SIZE = 100
  class BetfairEvent < ApplicationRecord
    attr_accessible :menu_path, :menu_path_id, :description, :active, :starttime, :endtime, :live_priced, :exchange_id, :match_id, :match
    has_many :baskets, dependent: :destroy
    belongs_to :match
    has_many :bet_markets, dependent: :destroy
    belongs_to :sport, counter_cache: true
    belongs_to :menu_path
  end

  def up
    [CricketMatch, BaseballMatch, BasketballMatch, SnookerMatch, TennisMatch, SoccerMatch].each do |classname|
      processAll(classname) do |match|
        hometeam = Team.find match.hometeam_id
        awayteam = Team.find match.awayteam_id
        match.teams << hometeam
        match.teams << awayteam
        match.venue_id = hometeam.id
        match.name = "#{hometeam.teamname} v #{awayteam.teamname}"
        match.save!
      end
    end
    MotorRace.all.each do |race|
      winner = race.bet_markets.find { |m| m.name == "Winner" }
      if winner
        winner.market_runners.each do |runner|
          race.teams << race.sport.findTeam(runner.description)
        end
        race.venue_id = race.sport.findTeam(winner.menu_path_name[-1]).id
        race.name = winner.menu_path_name[-1]
        race.save!
      else
        say_with_time "Destroying race #{race.inspect}" do
          race.destroy
        end
      end
    end
    add_foreign_key :matches, :teams, column: :venue_id
    remove_column :matches, :hometeam_id
    remove_column :matches, :awayteam_id
  end

  def down
    change_table :matches do |t|
      t.integer :hometeam_id
      t.integer :awayteam_id
    end
    remove_foreign_key :matches, :teams
    [CricketMatch, BaseballMatch, BasketballMatch, SnookerMatch, TennisMatch, SoccerMatch].each do |classname|
      processAll(classname) do |match|
        match.hometeam_id = match.hometeam.id
        match.awayteam_id = match.awayteam.id
        match.save!
      end
    end

    remove_foreign_key :match_teams, :matches
    remove_foreign_key :match_teams, :teams
    drop_table :match_teams
  end

private

  def processAll(classname, &block)
    index = 0
    count = classname.count
    start = Time.zone.now
    classname.find_in_batches(batch_size: BATCH_SIZE, include: :bet_markets) do |match_group|
      percent = (100.0 * index / count)
      now = Time.zone.now
      elapsed = now - start
      eta = start
      eta += (100 * elapsed / percent) if percent > 0
      say_with_time "#{classname} #{index}/#{count} #{percent.round(3)}% start #{start} ETA #{eta}" do
        classname.transaction do
          match_group.each(&block)
          index += BATCH_SIZE
        end
      end
    end
  end
end

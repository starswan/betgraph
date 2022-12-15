# frozen_string_literal: true

#
# $Id$
#
class MoveEventColumnsToMatch < ActiveRecord::Migration[4.2]
  BATCH_SIZE = 100
  class BetfairEvent < ApplicationRecord
    attr_accessible :menu_path, :menu_path_id, :description, :active, :starttime, :endtime, :live_priced, :exchange_id, :match_id, :match
    has_many :baskets, dependent: :destroy
    belongs_to :match
    has_many :bet_markets, dependent: :destroy
    belongs_to :sport, counter_cache: true
    belongs_to :menu_path

    before_create do |event|
      event.active = true
    end

    after_create :create_baskets_from_rules

    before_update do |event|
      if event.live_priced_changed?
        event.bet_markets.each do |bm|
          bm.live_priced = event.live_priced
        end
      end
      if event.active_changed?
        event.bet_markets.each do |bm|
          bm.active = event.active
        end
      end
    end

    def create_baskets_from_rules
      sport.basket_rules.each do |basket_rule|
        baskets.create! name: basket_rule.name, missing_items_count: basket_rule.count
      end
    end

    def self.find_all_under_path(menu_path)
      self.all.find_all { |e| e.menu_path_name[0..menu_path.size - 1] == menu_path }
    end

    def self.activelive
      self.all joins: :bet_markets, group: "bet_markets.betfair_event_id", conditions: ["bet_markets.status != ? and starttime <= ? and betfair_events.active = ?", BetMarket::CLOSED, Time.now + 15.minutes, true], order: :starttime
    end

    # Decide whether this event represents a soccer match
    def soccermatch?
      %w[Soccer Football].member?(menu_path_name[0]) && (menu_path_name.size > 1) && (menu_path_name[-1].size > 8) && fixture?
    end

    def shortname
      ourname = menu_path.name
      ourname = ourname[1..ourname.size] if (ourname[0] == "Soccer") && (ourname.size > 1)
      ourname = ourname[1..ourname.size] if (ourname[0] == "English Soccer") && (ourname.size > 1)
      ourname = ourname[1..ourname.size] if ourname[0] == "Scottish Soccer"
      ourname = ourname[1..-1] if ourname[0] == "Italian Soccer"
      ourname = ourname[1..-1] if ourname[0] == "German Soccer"
      ourname = ourname[1..-1] if ourname[0] == "Spanish Soccer"
      ourname = ourname[1..-1] if ourname[0] == "French Soccer"
      ourname = ourname[1..-1] if ourname[0] == "Dutch Soccer"
      ourname = ourname[0..ourname.size - 2] if ourname[-1] == "Leg Betting"
      ourname = ourname[0..ourname.size - 2] if fixture?
      ourname = ourname[1..ourname.size - 2] if (ourname[0] == "Darts") && ourname[-1].include?("Matches")
      ourname = ourname[1..ourname.size] if ourname[0] == "Darts"

      ourname = ourname[0..-2] if (ourname[0] == "Snooker") && (ourname[-1] == "Frame Betting")
      ourname = ourname[1..-1] if ourname[0] == "Snooker"
      ourname = ourname[1..-1] if ourname[0] == "Motor Sport"
      ourname.size > 1 ? ourname : ourname[0]
    end

    def longname
      menu_path.name + [description]
    end

    def has_market?(marketid)
      !bet_markets.find_index { |bm| bm.marketid == marketid }.nil?
    end

    def isactive?
      (starttime <= Time.now + 15.minutes) && (endtime >= Time.now - 15.minutes)
    end

    def timeOffsetInMinutes(thetime)
      ((thetime - starttime) / 60).round(3)
    end

    def fixture?
      if menu_path.name.blank?
        false
      elsif menu_path.name[-1].start_with?("Daily Goals")
        false
      else
        (menu_path.name[-1].index("Fixture") == 0) ||
          (menu_path.name[-1].index("Fixtures") == menu_path.name[-1].size - 8) ||
          (menu_path.name[-2].index("Fixtures") == menu_path.name[-2].size - 8) ||
          (menu_path.name[-2].index("Fixture") == 0)
      end
    end
  end

  class Basket < ApplicationRecord
    attr_accessible :name, :missing_items_count
    belongs_to :match
    belongs_to :betfair_event
    has_many :basket_items, dependent: :destroy
    has_many :event_basket_prices, dependent: :destroy

    validates_presence_of :missing_items_count
  end

  def up
    change_table :matches do |t|
      t.datetime :endtime, null: false
      t.string :name, null: false
      t.boolean :deleted, null: false, default: false
      t.boolean :live_priced, null: false, default: false
      t.references :venue, class: "Team", null: false
      t.integer :bet_markets_count, :integer, null: false, default: 0
    end
    create_table :match_teams do |t|
      t.references :match, null: false
      t.references :team, null: false
      t.timestamps
    end
    add_foreign_key :match_teams, :matches
    add_foreign_key :match_teams, :teams
    Match.reset_column_information
    Match.find_by_sql("select * from matches where type = ''").each do |match|
      match.name = "Unknown"
      match.type = "SoccerMatch"
      match.venue_id = 0
      match.save!
    end
    MotorRace.all.each do |race|
      winner = race.bet_markets.find { |m| m.name == "Winner" }
      if winner
        winner.market_runners.each do |runner|
          race.teams << race.sport.findTeam(runner.description)
        end
        race.venue = race.sport.findTeam(winner.menu_path_name[-1])
        race.name = winner.menu_path_name[-1]
        race.save!
      else
        say_with_time "Destroying race #{race.name}" do
          race.destroy
        end
      end
    end
    processAllMatches do |match, event|
      hometeam = awayteam = nil
      hometeam = Team.find_by id: match.hometeam_id if match.hometeam_id
      awayteam = Team.find_by id: match.awayteam_id if match.awayteam_id
      if event
        match.name = event.description
        match.endtime = event.endtime
        match.live_priced = event.live_priced
      else
        match.endtime = match.kickofftime + match.division.sport.expiry_time_in_minutes.minutes
        match.name = "Unknown"
        match.name = hometeam.name + " v " + awayteam.name if hometeam && awayteam
      end
      match.venue = hometeam if hometeam
      match.save!
    end
    remove_foreign_key :betfair_events, :menu_paths
    remove_foreign_key :bet_markets, :betfair_events
    remove_column :bet_markets, :betfair_event_id
    drop_table :betfair_events
  end

  def down
    create_table "betfair_events", force: true do |t|
      t.datetime "starttime"
      t.datetime "endtime"
      t.timestamps
      t.string   "description", limit: 50, null: false
      t.integer  "sport_id",                                      null: false
      t.boolean  "active",                                        null: false
      t.boolean  "live_priced", default: false, null: false
      t.integer  "exchange_id",                                   null: false
      t.integer  "match_id",                                      null: false
      t.integer  "menu_path_id",                                  null: false
    end

    add_column :bet_markets, :betfair_event_id, null: false

    remove_column :matches, :bet_markets_count
    remove_column :matches, :venue_id
    remove_column :matches, :endtime
    remove_column :matches, :name
    remove_column :matches, :deleted
    remove_column :matches, :live_priced
  end

private

  def processAll(classname)
    index = 0
    count = classname.count
    start = Time.now
    classname.find_in_batches(batch_size: BATCH_SIZE, include: :bet_markets) do |match_group|
      percent = (100.0 * index / count)
      now = Time.now
      elapsed = now - start
      eta = start
      eta += (100 * elapsed / percent) if percent > 0
      say_with_time "#{classname} #{index}/#{count} #{percent.round(3)}% start #{start} ETA #{eta}" do
        classname.transaction do
          match_group.each { |match| yield(match) }
          index += BATCH_SIZE
        end
      end
    end
  end

  def processAllMatches
    processAll(Match) do |match|
      event = BetfairEvent.find_by match_id: match
      yield match, event
    end
  end
end

# frozen_string_literal: true

#
# $Id$
#
class MoveBasketsToMatch < ActiveRecord::Migration[4.2]
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
        basket = baskets.create! name: basket_rule.name, missing_items_count: basket_rule.count
      end
    end

    def longname
      menu_path.name + [description]
    end

    def has_market?(marketid)
      !bet_markets.find_index { |bm| bm.marketid == marketid }.nil?
    end

    def isactive?
      (starttime <= Time.zone.now + 15.minutes) && (endtime >= Time.zone.now - 15.minutes)
    end

    def timeOffsetInMinutes(thetime)
      ((thetime - starttime) / 60).round(3)
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
    change_table :baskets do |t|
      t.references :match, null: false
    end
    Basket.reset_column_information
    processAllEvents do |match, event|
      event.baskets.each do |basket|
        basket.match_id = match.id
        basket.save!
      end
    end
    add_foreign_key :baskets, :matches
    remove_column :baskets, :betfair_event_id
  end

  def down
    change_table :baskets do |t|
      t.references :betfair_event, null: false
    end
    remove_foreign_key :baskets, :matches
    processAllEvents do |_match, event|
      Basket.find_all_by_betfair_event_id(event.id).each do |basket|
        basket.betfair_event_id = event.id
        basket.save!
      end
    end
    remove_column :baskets, :match_id
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

  def processAllMatches
    processAll(Match) do |match|
      event = BetfairEvent.find_by match_id: match
      yield match, event
    end
  end

  def processAllEvents
    processAll(BetfairEvent) do |event|
      yield event.match, event
    end
  end
end

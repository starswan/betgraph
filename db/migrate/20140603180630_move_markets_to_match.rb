# frozen_string_literal: true

#
# $Id$
#
class MoveMarketsToMatch < ActiveRecord::Migration[4.2]
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
    change_table :bet_markets do |t|
      t.references :match, null: false
      t.references :menu_path, null: false
      t.integer :exchange_id, null: false
    end

    processAllEvents do |match, event|
      event.bet_markets.each do |bet_market|
        bet_market.match_id = match.id
        bet_market.menu_path_id = event.menu_path.id
        bet_market.exchange_id = event.exchange_id
        bet_market.save!
      end
    end
    add_foreign_key :bet_markets, :matches
    add_foreign_key :bet_markets, :menu_paths
  end

  def down
    remove_foreign_key :bet_markets, :menu_paths
    remove_foreign_key :bet_markets, :matches
    processAllEvents do |match, event|
      match.bet_markets do |bet_market|
        bet_market.betfair_event_id = event.id
        bet_market.save!
      end
    end
    remove_column :bet_markets, :exchange_id
    remove_column :bet_markets, :match_id
    remove_column :bet_markets, :menu_path_id
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
      say_with_time "#{classname} #{index}/#{count} #{percent.round(3)}% eta #{eta}" do
        classname.transaction do
          match_group.each { |match| yield(match) }
          index += BATCH_SIZE
        end
      end
    end
  end

  def processAllEvents
    processAll(BetfairEvent) do |event|
      yield event.match, event
    end
  end
end

# frozen_string_literal: true

#
# $Id$
#
class RemoveBasketOrphans < ActiveRecord::Migration[4.2]
  BATCH_SIZE = 100
  class BetfairEvent < ApplicationRecord
    attr_accessible :menu_path, :menu_path_id, :description, :active, :starttime, :endtime, :live_priced, :exchange_id, :match_id, :match
    has_many :baskets, dependent: :destroy
    belongs_to :match
    has_many :bet_markets, dependent: :destroy
    belongs_to :sport, counter_cache: true
    belongs_to :menu_path
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
    orphan_baskets = Basket.includes(:betfair_event).find_each.select { |b| b.betfair_event.nil? }
    orphan_baskets.each_with_index do |b, index|
      say_with_time "Orphan basket #{index}/#{orphan_baskets.size}" do
        b.destroy
      end
    end
  end

  def down; end

private
end

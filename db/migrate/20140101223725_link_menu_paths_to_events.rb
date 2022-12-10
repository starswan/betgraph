# frozen_string_literal: true

#
# $Id$
#
class LinkMenuPathsToEvents < ActiveRecord::Migration[4.2]
  # class MigrationBetMarket < ActiveRecord::Base
  #  self.table_name = :bet_markets
  #  has_many :market_runners, :dependent => :destroy, :foreign_key => :bet_market_id
  # end

  class MigrationBetfairEvent < ApplicationRecord
    self.table_name = :betfair_events
    # Need this property during migration otherwise can't find any menu paths
    # Resulting in mass-deletions
    serialize :menu_path_name
    belongs_to :menu_path

    has_many :baskets, dependent: :destroy, foreign_key: :betfair_event_id
    # has_many :bet_markets, :class_name => 'MigrationBetMarket', :dependent => :destroy, :foreign_key => :betfair_event_id
    has_many :bet_markets, dependent: :destroy, foreign_key: :betfair_event_id
  end

  def up
    # remove_column :betfair_events, :menu_path_id
    add_column :betfair_events, :menu_path_id, :integer, null: false
    MigrationBetfairEvent.reset_column_information

    withAllEvents do |event|
      menu_path = MenuPath.findByName(event.menu_path_name)
      if menu_path
        event.menu_path_id = menu_path.id
        event.save!
      else
        say_with_time "Destroying #{event.inspect}" do
          event.destroy
        end
      end
    end
    add_foreign_key :betfair_events, :menu_paths, dependent: :delete

    remove_column :betfair_events, :menu_path_name
  end

  def down
    add_column :betfair_events, :menu_path_name, :string, null: false
    withAllEvents do |event|
      event.menu_path_name = event.menu_path.name
      event.save!
    end
    remove_foreign_key :betfair_events, :menu_paths
    remove_column :betfair_events, :menu_path_id
  end

private

  def withAllEvents
    count = MigrationBetfairEvent.count
    batchsize = 2000
    index = 0
    MigrationBetfairEvent.find_in_batches(batch_size: batchsize) do |event_group|
      say_with_time "#{event_group.first.inspect} #{index}/#{count}" do
        event_group.each do |event|
          yield event
        end
        index += batchsize
      end
    end
  end
end

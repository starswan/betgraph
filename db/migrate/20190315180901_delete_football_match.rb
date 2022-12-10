# frozen_string_literal: true

#
# $Id$
#
class DeleteFootballMatch < ActiveRecord::Migration[5.1]
  class FootballMatch < ApplicationRecord
    belongs_to :match
    belongs_to :football_season
  end

  BATCH_SIZE = 2500

  def up
    change_table :matches do |t|
      t.references :football_season
    end
    index, count = 0, FootballMatch.count
    FootballMatch.includes(:football_season, :match).find_in_batches(batch_size: BATCH_SIZE) do |batch|
      percent = "%.2f" % (100.0 * index / count)
      say_with_time "FootballMatch deletion #{index}/#{FootballMatch.count}(#{SoccerMatch.count}) #{percent}%" do
        FootballMatch.transaction do
          # slightly worrying that we had the odd unlinked football match
          batch.reject { |b| b.match.nil? }.each do |fm|
            fm.match.update!(football_season: fm.football_season)
            # fm.destroy
          end
        end
      end
      index += BATCH_SIZE
    end
    drop_table :football_matches
  end

  def down
    create_table :football_matches do |t|
      t.integer :football_season_id, null: false
      t.integer :match_id, null: false
      t.timestamps null: false
      t.index :match_id
    end

    index, count = 0, SoccerMatch.count
    SoccerMatch.find_in_batches(batch_size: BATCH_SIZE).each do |batch|
      percent = "%.2f" % (100.0 * index / count)
      say_with_time "FootballMatch creation #{index}/#{count} #{percent}%" do
        FootballMatch.transaction do
          batch.each do |match|
            FootballMatch.create! match: match, football_season: match.football_season
          end
        end
      end
      index += BATCH_SIZE
    end

    remove_column :matches, :football_season_id
  end
end

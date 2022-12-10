# frozen_string_literal: true

#
# $Id$
#
class ReworkForeignKeys < ActiveRecord::Migration[5.2]
  TABLES = [
    { from: :baskets, to: :matches, name: :baskets_match_id_fk },
    { from: :bet_markets, to: :matches, name: :bet_markets_match_id_fk },
    { from: :match_teams, to: :matches, name: :match_teams_match_id_fk },
    { from: :match_teams, to: :teams, name: :match_teams_team_id_fk },
  ].freeze
  def change
    TABLES.each do |table|
      remove_foreign_key table.fetch(:from), name: table.fetch(:name)
      add_foreign_key table.fetch(:from), table.fetch(:to)
    end
  end
end

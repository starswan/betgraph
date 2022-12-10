# frozen_string_literal: true

#
# $Id$
#
class AddMissingTeamForeignKeys < ActiveRecord::Migration[5.1]
  TABLES = [:team_totals, :team_names, :team_divisions, :scorers].freeze

  def up
    TeamTotal.includes(:team).find_in_batches.each do |batch|
      TeamTotal.transaction do
        batch.each { |tt| tt.destroy if tt.team.blank? }
      end
    end
    TeamDivision.includes(:team).find_in_batches.each do |batch|
      TeamTotal.transaction do
        batch.each { |tt| tt.destroy if tt.team.blank? }
      end
    end
    Scorer.includes(:team).find_in_batches.each do |batch|
      TeamTotal.transaction do
        batch.each { |tt| tt.destroy if tt.team.blank? }
      end
    end

    TABLES.each do |name|
      add_foreign_key name, :teams
    end
  end

  def down
    TABLES.each do |name|
      remove_foreign_key name, :teams
    end
  end
end

# frozen_string_literal: true

#
# $Id$
#
class AddIndexesToTeamTotals < ActiveRecord::Migration[4.2]
  BATCH_SIZE = 2000
  TT_FIELDS = [:count, :total_goals, :team_id].freeze

  def up
    TT_FIELDS.each { |field| add_index(:team_totals, field) }
    # first_match_id = Match.order(:id).first.id
    # TeamTotal.where('match_id < ?', first_match_id).destroy_all
    1.upto TeamTotalConfig.order("count desc").first.count do |value|
      remove_unused_team_totals value
    end
    add_foreign_key :team_totals, :matches
  end

  def down
    remove_foreign_key :team_totals, :matches
    TT_FIELDS.each { |field| remove_index(:team_totals, column: field) }
  end

private

  def remove_unused_team_totals(count_value)
    scope = TeamTotal.where("count = ?", count_value)
    index, count = 0, scope.count
    scope.find_in_batches(batch_size: BATCH_SIZE) do |group|
      percent = (10000 * index / count) / 100.0
      say_with_time "TeamTotal(#{count_value}) #{index}/#{count} #{percent}% #{scope.count}" do
        TeamTotal.transaction do
          group.each do |team_total|
            unless team_total.match
              TeamTotal.where(match_id: team_total.match_id).delete_all
            end
          end
        end
      end
      index += group.size
    end
  end
end

# frozen_string_literal: true

#
# $Id$
#
class Team < ApplicationRecord
  has_many :team_names, dependent: :destroy
  has_many :team_totals, dependent: :destroy
  belongs_to :sport, inverse_of: :teams
  has_many :match_teams, dependent: :delete_all # Join table items can just be deleted.
  has_many :matches, through: :match_teams
  has_many :scorers, dependent: :destroy

  has_many :team_divisions, dependent: :delete_all
  has_many :divisions, through: :team_divisions

  delegate :count, to: :matches, prefix: true

  scope :for_sport, ->(sport) { where(sport: sport) }

  before_destroy do |team|
    Match.where(venue_id: team.id).destroy_all
  end

  def name
    # team_names.count == 0 ? "" : team_names.first.name
    firstname = team_names.last
    firstname ? firstname.name : ""
  end

  def name=(teamname)
    team_names << TeamName.create(name: teamname)
  end

  def teamname
    team_names.last.name
  end
end

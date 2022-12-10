# frozen_string_literal: true

#
# $Id$
#
class Sport < ApplicationRecord
  validates :name, :betfair_sports_id, presence: true

  validates :betfair_sports_id, uniqueness: true

  has_many :menu_paths, dependent: :destroy

  has_many :betfair_market_types, dependent: :destroy
  has_many :basket_rules, dependent: :destroy
  has_many :calendars, dependent: :destroy
  has_many :teams, dependent: :destroy

  has_many :seasons, through: :calendars
  has_many :divisions, through: :calendars
  has_many :matches, through: :divisions

  before_create do |sport|
    sport.match_type = "MotorRace" if sport.name == "Motor Sport"
    sport.match_type ||= "#{sport.name}Match"
  end

  after_create do |sport|
    sport.menu_paths.create! depth: 1, name: [sport.name], active: false
  end

  scope :active, -> { where(active: true) }

  def top_menu_paths
    top_paths = menu_paths.where(parent_path_id: nil)
    top_paths.map(&:menu_paths).append(top_paths).flatten
  end

  def findTeam(team_name)
    team = teams.joins(:team_names).where("team_names.name = ?", team_name).first
    team || teams.create!(name: team_name)
  end
end

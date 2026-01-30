# frozen_string_literal: true

#
# $Id$
#
class Match < ApplicationRecord
  include Discard::Model
  self.discard_column = :deleted_at

  before_validation :add_season, if: -> { division.present? && kickofftime.present? }

  belongs_to :division, inverse_of: :matches
  has_one :result, dependent: :destroy
  has_many :team_totals, dependent: :destroy

  validates :kickofftime, :type, :name, :division_id, presence: true
  belongs_to :venue, class_name: "Team", optional: true

  has_many :match_teams, dependent: :destroy
  has_many :teams, through: :match_teams
  has_many :bet_markets, dependent: :destroy
  has_many :baskets, dependent: :destroy
  has_many :market_runners, through: :bet_markets
  has_many :market_prices, through: :market_runners

  # Motor Races don't have seasons - need to fix
  belongs_to :season, inverse_of: :matches, optional: true

  validates :date, uniqueness: { scope: %i[venue_id deleted_at] }

  before_save do |match|
    match.date = match.kickofftime.to_date
  end

  scope :ordered_by_date, -> { order(:kickofftime) }
  scope :earlier_than, ->(datetime) { kept.where("kickofftime <= ?", datetime) }
  scope :almost_live, -> { kept.where("kickofftime <= ?", Time.now + 15.minutes) }
  scope :live_priced, -> { kept.where(live_priced: true) }
  scope :future, -> { kept.where("kickofftime >= ?", Time.now) }
  scope :played_on, ->(date) { kept.where("kickofftime >= ?", date.to_date).where("kickofftime < ?", (date + 1.day).to_date) }
  scope :with_prices, -> { kept.where.not(market_prices_count: 0) }

  scope :activelive, lambda {
    almost_live.joins(:bet_markets).merge(BetMarket.not_closed_or_suspended).distinct
  }

  before_create do |match|
    match.endtime = match.kickofftime + match.division.calendar.sport.expiry_time_in_minutes.minutes
  end

  after_create :create_baskets_from_rules

  def homegoals(mins)
    teamscore hometeam.id, mins
  end

  def awaygoals(mins)
    teamscore awayteam.id, mins
  end

  def homescorers
    scorers.select { |scorer| scorer.team == hometeam }
  end

  def awayscorers
    scorers.select { |scorer| scorer.team == awayteam }
  end

  def homescorercount
    scorers.count { |scorer| scorer.team == hometeam }
  end

  def awayscorercount
    scorers.count { |scorer| scorer.team == awayteam }
  end

  delegate :sport, to: :division

  class << self
    def ransackable_attributes(_auth_object = nil)
      %w[actual_start_time bet_markets_count created_at date deleted_at division_id endtime half_time_duration id kickofftime live_priced market_prices_count name season_id type updated_at venue_id]
    end
  end

private

  def create_baskets_from_rules
    division.calendar.sport.basket_rules.each do |basket_rule|
      baskets.create! basket_rule: basket_rule, missing_items_count: basket_rule.count
    end
  end

  def teamscore(team_id, mins)
    scorers.inject(0) do |total, scorer|
      total += 1 if scorer.goaltime <= mins && scorer.team_id == team_id; total
    end
  end

  def add_season
    # season = Season.where("startdate <= ?", kickofftime).order(:startdate).last
    self.season = division.calendar.seasons.where("startdate <= ?", kickofftime).order(:startdate).last
  end
end

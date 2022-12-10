# frozen_string_literal: true

#
# $Id$
#
class Match < ApplicationRecord
  acts_as_paranoid

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
  has_many :market_prices, through: :bet_markets

  # Motor Races don't have seasons - need to fix
  belongs_to :season, inverse_of: :matches, optional: true

  validates :date, uniqueness: { scope: [:venue_id, :deleted_at] }

  before_save do |match|
    match.date = match.kickofftime.to_date
  end

  scope :ordered_by_date, -> { order(:kickofftime) }
  scope :earlier_than, ->(datetime) { where("kickofftime <= ?", datetime) }
  scope :almost_live, -> { where("kickofftime <= ?", Time.now + 15.minutes) }
  scope :live_priced, -> { where(live_priced: true) }

  scope :activelive, lambda {
    where("bet_markets.status != ? and kickofftime <= ?", BetMarket::CLOSED, Time.now + 15.minutes)
      .joins(:bet_markets).group("matches.id")
  }

  scope :with_prices, -> { where.not(market_prices_count: 0) }

  before_create do |match|
    match.endtime = match.kickofftime + match.division.calendar.sport.expiry_time_in_minutes.minutes
  end

  after_create do |match|
    match.create_baskets_from_rules
  end

  def create_baskets_from_rules
    division.calendar.sport.basket_rules.each do |basket_rule|
      baskets.create! basket_rule: basket_rule, missing_items_count: basket_rule.count
    end
  end

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

private

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

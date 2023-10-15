# frozen_string_literal: true

#
# $Id$
#
class Division < ApplicationRecord
  belongs_to :calendar

  has_one :football_division, dependent: :destroy
  has_many :matches, dependent: :destroy
  has_many :competitions, dependent: :destroy
  has_many :seasons, through: :calendar

  # These rules blow-up active admin divisions section
  # has_many :soccer_matches
  scope :soccer_matches, -> { matches.where(type: "SoccerMatch") }
  # has_many :tennis_matches
  # has_many :snooker_matches

  validates :name, presence: true
  # This allows us to validate uniqueness of fixtures for everyone except scotland
  validates :scottish, inclusion: { in: [true, false] }

  scope :active, -> { where(active: true) }

  def find_match(hometeam, awayteam, start_time)
    date = start_time.to_date
    matches.where(venue: hometeam).where("kickofftime >= ? and kickofftime <= ?", date, date + 1.day)
           .find { |match| match.teams.include? awayteam }
  end

  delegate :sport, to: :calendar
end

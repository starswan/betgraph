# frozen_string_literal: true

#
# $Id$
#
class Season < ApplicationRecord
  attr_accessor :threshold

  validates :startdate, uniqueness: { scope: :calendar_id }
  validates :name, presence: true

  has_many :matches, inverse_of: :season
  belongs_to :calendar, inverse_of: :seasons

  scope :online, -> { where(online: true) }
  scope :starting_within, lambda { |date, time_range|
                            where("startdate >= ?", date - time_range)
                                                   .where("startdate <= ?", date + time_range)
                          }

  def current?(today)
    enddate = startdate + 1.year
    startdate < today && today < enddate
  end
end

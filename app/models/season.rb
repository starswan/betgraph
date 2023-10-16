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
  scope :in_date_order, -> { order(:startdate) }
  scope :not_in_the_future, -> { where("startdate < ?", Time.zone.today) }

  def current?(today)
    enddate = startdate + 1.year
    startdate < today && today < enddate
  end

  class << self
    def ransackable_attributes(_auth_object = nil)
      %w[calendar_id created_at id name online startdate updated_at]
    end

    def ransackable_associations(_auth_object = nil)
      %w[calendar matches]
    end
  end
end

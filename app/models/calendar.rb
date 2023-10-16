# frozen_string_literal: true

class Calendar < ApplicationRecord
  belongs_to :sport

  has_many :seasons
  has_many :divisions, inverse_of: :calendar, dependent: :destroy

  validates :name, presence: true

  class << self
    def ransackable_attributes(_auth_object = nil)
      %w[id name sport_id]
    end

    def ransackable_associations(_auth_object = nil)
      %w[divisions seasons sport]
    end
  end
end

# frozen_string_literal: true

class Competition < ApplicationRecord
  belongs_to :sport, inverse_of: :competitions
  belongs_to :division, inverse_of: :competitions, optional: true

  scope :active, -> { where(active: true) }

  class << self
    def ransackable_attributes(_auth_object = nil)
      %w[active betfair_id created_at division_id id name region sport_id updated_at]
    end

    def ransackable_associations(_auth_object = nil)
      %w[division sport]
    end
  end
end

# frozen_string_literal: true

#
# $Id$
#
class TeamTotalConfig < ApplicationRecord
  validates :count, uniqueness: true
  validates :count, :threshold, :name, presence: true

  # simplecov:disable
  class << self
    def ransackable_attributes(_auth_object = nil)
      %w[name count threshold]
    end

    def self.ransackable_associations(_auth_object = nil)
      []
    end
  end
  # simplecov:enable
end

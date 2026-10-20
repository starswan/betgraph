# frozen_string_literal: true

#
# $Id$
#
class TeamTotalConfig < ApplicationRecord
  validates :count, uniqueness: true
  validates :count, :threshold, :name, presence: true

  class << self
    # simplecov:disable
    def ransackable_attributes(_auth_object = nil)
      %w[name count threshold]
    end
    # simplecov:enable
  end
end

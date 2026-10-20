# frozen_string_literal: true

#
# $Id$
#
class TeamTotalConfig < ApplicationRecord
  #   attr_accessible :count, :threshold, :name
  validates :count, uniqueness: true
  validates :count, :threshold, :name, presence: true

  class << self
    def ransackable_attributes(_auth_object = nil)
      %w[name count threshold]
    end
  end
end

# frozen_string_literal: true

#
# $Id$
#
class TeamName < ApplicationRecord
  belongs_to :team
  # TODO: name is only unique within sport (c.f. India in both football and cricket)
  # validates_uniqueness_of :name
  validates :name, presence: { strict: true }
end

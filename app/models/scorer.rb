# frozen_string_literal: true

#
# $Id$
#
class Scorer < ApplicationRecord
  belongs_to :match
  belongs_to :team
  validates :name, :goaltime, presence: true

  scope :before, ->(seconds) { where("goaltime <= ?", seconds) }
  scope :for_team, ->(team) { where(team: team) }
end

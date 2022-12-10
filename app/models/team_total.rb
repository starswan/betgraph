# frozen_string_literal: true

#
# $Id$
#
class TeamTotal < ApplicationRecord
  belongs_to :team
  belongs_to :match

  scope :by_count, ->(count) { where(count: count) }
end

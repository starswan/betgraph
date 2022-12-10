# frozen_string_literal: true

#
# $Id$
#
class TeamTotalConfig < ApplicationRecord
  #   attr_accessible :count, :threshold, :name
  validates :count, uniqueness: true
  validates :count, :threshold, :name, presence: true
end

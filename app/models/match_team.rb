# frozen_string_literal: true

#
# $Id$
#
class MatchTeam < ApplicationRecord
  belongs_to :match
  belongs_to :team
end

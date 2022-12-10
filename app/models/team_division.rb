# frozen_string_literal: true

#
# $Id$
#
# This appears to be an hopeful addition
# not completely implemented at all...
class TeamDivision < ApplicationRecord
  belongs_to :team
  belongs_to :division
end

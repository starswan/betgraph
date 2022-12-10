# frozen_string_literal: true

#
# $Id$
#
# Used to provide a code for the external football_data loading script from http://www.football-data.co.uk/
# which links back to Division model.
class FootballDivision < ApplicationRecord
  belongs_to :division
end

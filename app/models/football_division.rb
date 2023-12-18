# frozen_string_literal: true

#
# $Id$
#
# Used to provide a code for the external football_data loading script from http://www.football-data.co.uk/
# which links back to Division model.
class FootballDivision < ApplicationRecord
  belongs_to :division

  class << self
    def ransackable_attributes(_auth_object = nil)
      %w[bbc_slug created_at division_id football_data_code id rapid_api_country rapid_api_name updated_at]
    end

    def ransackable_associations(_auth_object = nil)
      %w[division]
    end
  end
end

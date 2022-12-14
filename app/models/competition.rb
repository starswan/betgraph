# frozen_string_literal: true

class Competition < ApplicationRecord
  belongs_to :sport, inverse_of: :competitions
  belongs_to :division, inverse_of: :competitions, optional: true

  scope :active, -> { where(active: true) }
end

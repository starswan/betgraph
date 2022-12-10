# frozen_string_literal: true

class Calendar < ApplicationRecord
  belongs_to :sport

  has_many :seasons
  has_many :divisions, inverse_of: :calendar, dependent: :destroy

  validates :name, presence: true
end

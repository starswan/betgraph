# frozen_string_literal: true

class RemoveDivisionSportId < ActiveRecord::Migration[6.0]
  def change
    remove_column :divisions, :sport_id, :bigint
  end
end

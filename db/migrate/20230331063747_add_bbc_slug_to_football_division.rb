# frozen_string_literal: true

class AddBbcSlugToFootballDivision < ActiveRecord::Migration[6.1]
  def change
    change_table :football_divisions do |t|
      t.string :bbc_slug, limit: 30
    end
  end
end

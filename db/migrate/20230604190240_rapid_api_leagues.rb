# frozen_string_literal: true

class RapidApiLeagues < ActiveRecord::Migration[6.1]
  def change
    change_table :football_divisions, bulk: true do |t|
      t.string :rapid_api_country
      t.string :rapid_api_name
    end
  end
end

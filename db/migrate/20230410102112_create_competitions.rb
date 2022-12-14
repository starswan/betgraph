# frozen_string_literal: true

class CreateCompetitions < ActiveRecord::Migration[6.1]
  def change
    create_table :competitions do |t|
      t.string :name, null: false
      t.references :sport, null: false
      t.integer :betfair_id, null: false
      t.boolean :active, null: false, default: false
      t.string :region, null: false
      t.references :division

      t.timestamps
    end

    change_column_null :market_runners, :asianLineId, true
  end
end

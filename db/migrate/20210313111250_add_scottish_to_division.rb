# frozen_string_literal: true

#
# $Id$
#
class AddScottishToDivision < ActiveRecord::Migration[5.2]
  def change
    change_table :divisions do |t|
      t.boolean :scottish, default: false, null: false
    end

    Division.all.each do |division|
      division.update(scottish: true) if division.name.starts_with?("Scottish")
    end
  end
end

# frozen_string_literal: true

class IncreaseBmtParam1Precision < ActiveRecord::Migration[6.0]
  def change
    change_column :betfair_market_types, :param1, :decimal, precision: 7, scale: 2
  end
end

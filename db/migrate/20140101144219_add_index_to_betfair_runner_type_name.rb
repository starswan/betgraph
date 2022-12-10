# frozen_string_literal: true

#
# $Id$
#
class AddIndexToBetfairRunnerTypeName < ActiveRecord::Migration[4.2]
  def change
    add_index :betfair_runner_types, :name
  end
end

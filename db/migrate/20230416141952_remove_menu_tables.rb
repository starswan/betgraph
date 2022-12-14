# frozen_string_literal: true

class RemoveMenuTables < ActiveRecord::Migration[6.1]
  def change
    drop_table "menu_sub_paths" do |t|
      t.bigint "menu_path_id", null: false
      t.bigint "parent_path_id", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["menu_path_id"], name: "index_menu_sub_paths_on_menu_path_id"
      t.index ["parent_path_id"], name: "index_menu_sub_paths_on_parent_path_id"
    end

    drop_table "menu_paths" do |t|
      t.boolean "active", default: true, null: false
      t.integer "depth", default: 0, null: false
      t.string "name", null: false
      t.bigint "parent_path_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean "activeChildren", default: false
      t.boolean "activeGrandChildren", default: false
      t.bigint "division_id"
      t.bigint "sport_id", null: false
      t.index ["depth"], name: "index_menu_paths_on_depth"
      t.index ["division_id"], name: "fk_rails_1755b82e5d"
      t.index ["name"], name: "index_menu_paths_on_name", unique: true
      t.index ["parent_path_id"], name: "index_menu_paths_on_parent_path_id"
      t.index ["sport_id"], name: "fk_rails_11b4a797c2"
    end
  end
end

# frozen_string_literal: true

#
# $Id$
#
class InitialLoad2012 < ActiveRecord::Migration[4.2]
  def up
    create_table "basket_items", id: :integer, force: :cascade do |t|
      t.integer "basket_id"
      t.integer "market_runner_id"
      t.integer "weighting"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["basket_id"], name: "index_basket_items_on_basket_id"
    end

    create_table "basket_rule_items", id: :integer, force: :cascade do |t|
      t.integer "basket_rule_id", null: false
      t.integer "betfair_runner_type_id", null: false
      t.integer "weighting", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "basket_rules", id: :integer, force: :cascade do |t|
      t.integer "sport_id", null: false
      t.string "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "baskets", id: :integer, force: :cascade do |t|
      t.integer "event_id"
      t.string "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "missing_items_count", null: false
      t.integer "basket_items_count", default: 0, null: false
      t.index ["event_id"], name: "index_baskets_on_event_id"
    end

    create_table "bdrb_job_queues", id: :integer, force: :cascade do |t|
      t.text "args"
      t.string "worker_name"
      t.string "worker_method"
      t.string "job_key"
      t.integer "taken"
      t.integer "finished"
      t.integer "timeout"
      t.integer "priority"
      t.datetime "submitted_at"
      t.datetime "started_at"
      t.datetime "finished_at"
      t.datetime "archived_at"
      t.string "tag"
      t.string "submitter_info"
      t.string "runner_info"
      t.string "worker_key"
      t.datetime "scheduled_at"
    end

    create_table "bet_markets", id: :integer, force: :cascade do |t|
      t.integer "event_id", null: false
      t.integer "marketid", null: false
      t.string "name", limit: 50
      t.string "markettype", limit: 1, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "status", limit: 10
      t.integer "betfair_market_type_id", null: false
      t.string "menu_path_name", null: false
      t.integer "number_of_winners", null: false
      t.string "description", null: false
      t.string "type_variant", limit: 3, null: false
      t.boolean "runners_may_be_added", null: false
      t.datetime "time", null: false
      t.boolean "live", null: false
      t.datetime "nextUpdateTime", null: false
      t.boolean "active", default: true, null: false
      t.index ["active"], name: "index_bet_markets_on_active"
      t.index ["betfair_market_type_id"], name: "index_bet_markets_on_betfair_market_type_id"
      t.index ["event_id"], name: "bet_market_event_id"
      t.index ["marketid"], name: "index_bet_markets_on_marketid", unique: true
      t.index ["status"], name: "index_bet_markets_on_status"
    end

    create_table "betfair_market_types", id: :integer, force: :cascade do |t|
      t.string "name", null: false
      t.boolean "active", default: true
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "valuer", null: false
      t.integer "sport_id", null: false
      t.decimal "param1", precision: 5, scale: 2, default: "0.0", null: false
      t.index ["sport_id"], name: "index_betfair_market_types_on_sport_id"
    end

    create_table "betfair_runner_types", id: :integer, force: :cascade do |t|
      t.string "name", null: false
      t.integer "betfair_market_type_id", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "runnertype", null: false
      t.decimal "runnerhomevalue", precision: 5, scale: 2, null: false
      t.decimal "runnerawayvalue", precision: 5, scale: 2, null: false
      t.index ["betfair_market_type_id"], name: "index_betfair_runner_types_on_betfair_market_type_id"
    end

    create_table "divisions", id: :integer, force: :cascade do |t|
      t.string "name", limit: 50, null: false
      t.integer "odds_numerator", default: 8, null: false
      t.integer "odds_denominator", default: 1, null: false
      t.boolean "active", default: false, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "sport_id", null: false
    end

    create_table "event_basket_prices", id: :integer, force: :cascade do |t|
      t.integer "basket_id"
      t.datetime "time"
      t.decimal "price", precision: 7, scale: 5
      t.bigint "betsize"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["basket_id"], name: "index_event_basket_prices_on_basket_id"
    end

    create_table "events", id: :integer, force: :cascade do |t|
      t.datetime "starttime"
      t.datetime "endtime"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "description", limit: 50, null: false
      t.integer "sport_id", null: false
      t.boolean "active", null: false
      t.string "menu_path_name", null: false
      t.boolean "live_priced", default: false, null: false
      t.index ["description"], name: "index_events_on_description"
      t.index ["sport_id"], name: "index_events_on_sport_id"
      t.index ["starttime"], name: "index_events_on_starttime"
    end

    create_table "football_divisions", id: :integer, force: :cascade do |t|
      t.integer "division_id", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "football_data_code", limit: 3
    end

    create_table "football_seasons", id: :integer, force: :cascade do |t|
      t.string "name"
      t.integer "soccerbasenumber"
      t.date "startdate"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "logins", id: :integer, force: :cascade do |t|
      t.string "name"
      t.binary "username"
      t.binary "password"
    end

    create_table "market_price_times", id: :integer, force: :cascade do |t|
      t.integer "bet_market_id", null: false
      t.datetime "time", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["bet_market_id"], name: "index_market_price_times_on_bet_market_id"
      t.index ["time", "bet_market_id"], name: "index_market_price_times_on_time_and_bet_market_id"
    end

    create_table "market_prices", id: :integer, force: :cascade do |t|
      t.integer "market_runner_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.decimal "back1price", precision: 6, scale: 3
      t.decimal "lay1price", precision: 6, scale: 3
      t.decimal "back2price", precision: 6, scale: 3
      t.decimal "lay2price", precision: 6, scale: 3
      t.decimal "back3price", precision: 6, scale: 3
      t.decimal "lay3price", precision: 6, scale: 3
      t.decimal "back1amount", precision: 8, scale: 2
      t.decimal "lay1amount", precision: 8, scale: 2
      t.decimal "back2amount", precision: 8, scale: 2
      t.decimal "lay2amount", precision: 8, scale: 2
      t.decimal "back3amount", precision: 8, scale: 2
      t.decimal "lay3amount", precision: 8, scale: 2
      t.integer "market_price_time_id", null: false
      t.index ["market_price_time_id"], name: "index_market_prices_on_market_price_time_id"
      t.index ["market_runner_id"], name: "market_prices_market_runner_id"
    end

    create_table "market_runners", id: :integer, force: :cascade do |t|
      t.integer "bet_market_id", null: false
      t.integer "selectionId", null: false
      t.string "description", null: false
      t.decimal "handicap", precision: 5, scale: 2
      t.integer "asianLineId", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "sortorder"
      t.integer "market_prices_count", default: 0
      t.integer "betfair_runner_type_id", null: false
      t.index ["bet_market_id"], name: "index_market_runners_on_bet_market_id"
      t.index ["betfair_runner_type_id"], name: "index_market_runners_on_betfair_runner_type_id"
    end

    create_table "matches", id: :integer, force: :cascade do |t|
      t.integer "division_id", null: false
      t.integer "hometeam_id", null: false
      t.integer "awayteam_id", null: false
      t.datetime "kickofftime", null: false
      t.integer "event_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "actual_start_time"
      t.integer "half_time_duration", default: 900
      t.string "type", null: false
      t.index ["division_id", "awayteam_id", "kickofftime"], name: "index_matches_on_division_id_and_awayteam_id_and_kickofftime"
      t.index ["division_id", "hometeam_id", "kickofftime"], name: "index_matches_on_division_id_and_hometeam_id_and_kickofftime"
      t.index ["event_id"], name: "matches_event_id_fk"
      t.index ["kickofftime", "hometeam_id", "awayteam_id"], name: "index_matches_on_kickofftime_and_hometeam_id_and_awayteam_id"
      t.index ["kickofftime"], name: "index_matches_on_kickofftime"
    end

    create_table "menu_paths", id: :integer, force: :cascade do |t|
      t.boolean "active", default: true, null: false
      t.integer "depth", default: 0, null: false
      t.string "name", null: false
      t.integer "parent_path_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean "activeChildren", default: false
      t.boolean "activeGrandChildren", default: false
      t.integer "division_id"
      t.index ["name"], name: "index_menu_paths_on_name"
      t.index ["parent_path_id"], name: "index_menu_paths_on_parent_path_id"
    end

    create_table "menu_sub_paths", id: :integer, force: :cascade do |t|
      t.integer "menu_path_id", null: false
      t.integer "parent_path_id", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["menu_path_id"], name: "index_menu_sub_paths_on_menu_path_id"
      t.index ["parent_path_id"], name: "index_menu_sub_paths_on_parent_path_id"
    end

    create_table "prices", id: :integer, force: :cascade do |t|
      t.integer "market_runner_id"
      t.datetime "time"
      t.decimal "back1price", precision: 6, scale: 3
      t.decimal "back1amount", precision: 8, scale: 2
      t.decimal "lay1price", precision: 6, scale: 3
      t.decimal "lay1amount", precision: 8, scale: 2
      t.decimal "back2price", precision: 6, scale: 3
      t.decimal "back2amount", precision: 8, scale: 2
      t.decimal "lay2price", precision: 6, scale: 3
      t.decimal "lay2amount", precision: 8, scale: 2
      t.decimal "back3price", precision: 6, scale: 3
      t.decimal "back3amount", precision: 8, scale: 2
      t.decimal "lay3price", precision: 6, scale: 3
      t.decimal "lay3amount", precision: 8, scale: 2
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "results", id: :integer, force: :cascade do |t|
      t.integer "match_id", null: false
      t.integer "homescore", null: false
      t.integer "awayscore", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["match_id"], name: "index_results_on_match_id"
    end

    create_table "scorers", id: :integer, force: :cascade do |t|
      t.integer "match_id"
      t.integer "team_id"
      t.string "name"
      t.integer "goaltime"
      t.boolean "penalty"
      t.boolean "owngoal"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["match_id"], name: "index_scorers_on_match_id"
    end

    create_table "sports", id: :integer, force: :cascade do |t|
      t.string "name", null: false
      t.integer "menu_path_id", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "events_count", default: 0, null: false
      t.integer "betfair_sports_id"
      t.integer "expiry_time_in_minutes", default: 60, null: false
      t.index ["events_count"], name: "index_sports_on_events_count"
      t.index ["menu_path_id"], name: "index_sports_on_menu_path_id"
      t.index ["name"], name: "index_sports_on_name"
    end

    create_table "team_divisions", id: :integer, force: :cascade do |t|
      t.integer "team_id", null: false
      t.integer "division_id", null: false
      t.integer "season_id", null: false
      t.index ["team_id", "division_id", "season_id"], name: "index_team_divisions_on_team_id_and_division_id_and_season_id", unique: true
    end

    create_table "team_names", id: :integer, force: :cascade do |t|
      t.integer "team_id"
      t.string "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "team_total_configs", id: :integer, force: :cascade do |t|
      t.integer "count"
      t.integer "threshold"
      t.string "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "team_totals", id: :integer, force: :cascade do |t|
      t.integer "team_id"
      t.integer "count"
      t.integer "total_goals"
      t.integer "goals_for"
      t.integer "goals_against"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "match_id", null: false
      t.index ["match_id"], name: "index_team_totals_on_match_id"
    end

    create_table "teams", id: :integer, force: :cascade do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "sport_id"
    end

    create_table "trades", id: :integer, force: :cascade do |t|
      t.integer "market_runner_id"
      t.decimal "price", precision: 6, scale: 2, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.decimal "quantity", precision: 6, scale: 2, null: false
    end

    create_table "valuers", id: :integer, force: :cascade do |t|
      t.string "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_foreign_key "matches", "events", name: "matches_event_id_fk"
  end
end

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[6.1].define(version: 2024_02_28_200715) do

  create_table "active_admin_comments", charset: "utf8mb3", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "basket_items", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "basket_id"
    t.bigint "market_runner_id"
    t.integer "weighting"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["basket_id", "market_runner_id"], name: "index_basket_items_on_basket_id_and_market_runner_id", unique: true
    t.index ["basket_id"], name: "index_basket_items_on_basket_id"
    t.index ["market_runner_id"], name: "index_basket_items_on_market_runner_id"
  end

  create_table "basket_rule_items", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "basket_rule_id", null: false
    t.bigint "betfair_runner_type_id", null: false
    t.integer "weighting", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["basket_rule_id"], name: "fk_rails_a7edcdff9c"
    t.index ["betfair_runner_type_id"], name: "fk_rails_98d92a1e8b"
  end

  create_table "basket_rules", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "sport_id", null: false
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "count", default: 0, null: false
    t.index ["sport_id"], name: "fk_rails_3aa627174d"
  end

  create_table "baskets", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "missing_items_count", null: false
    t.integer "basket_items_count", default: 0, null: false
    t.bigint "match_id", null: false
    t.bigint "basket_rule_id", null: false
    t.index ["basket_rule_id"], name: "index_baskets_on_basket_rule_id"
    t.index ["match_id"], name: "baskets_match_id_fk"
  end

  create_table "bet_markets", charset: "utf8mb3", force: :cascade do |t|
    t.integer "marketid", null: false
    t.string "name", limit: 50
    t.string "markettype", limit: 20, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status", limit: 10
    t.bigint "betfair_market_type_id", null: false
    t.string "description", limit: 2000, null: false
    t.string "type_variant"
    t.datetime "time", null: false
    t.boolean "live", null: false
    t.boolean "active", default: true, null: false
    t.decimal "total_matched_amount", precision: 10, scale: 2, null: false
    t.integer "number_of_runners", null: false
    t.boolean "live_priced", default: false, null: false
    t.bigint "match_id", null: false
    t.integer "exchange_id", null: false
    t.integer "market_prices_count", default: 0, null: false
    t.integer "market_runners_count", default: 0, null: false
    t.datetime "deleted_at"
    t.bigint "version"
    t.string "price_source", null: false
    t.index ["active"], name: "index_bet_markets_on_active"
    t.index ["betfair_market_type_id"], name: "index_bet_markets_on_betfair_market_type_id"
    t.index ["deleted_at"], name: "index_bet_markets_on_deleted_at"
    t.index ["live"], name: "index_bet_markets_on_live"
    t.index ["marketid", "deleted_at"], name: "index_bet_markets_on_marketid_and_deleted_at", unique: true
    t.index ["match_id"], name: "bet_markets_match_id_fk"
    t.index ["name", "match_id", "deleted_at"], name: "index_bet_markets_on_name_and_match_id_and_deleted_at", unique: true
    t.index ["status"], name: "index_bet_markets_on_status"
  end

  create_table "betfair_market_types", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "valuer", null: false
    t.bigint "sport_id", null: false
    t.decimal "param1", precision: 7, scale: 2, default: "0.0", null: false
    t.index ["sport_id"], name: "index_betfair_market_types_on_sport_id"
  end

  create_table "betfair_runner_types", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "betfair_market_type_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "runnertype", null: false
    t.decimal "runnerhomevalue", precision: 5, scale: 2, null: false
    t.decimal "runnerawayvalue", precision: 5, scale: 2, null: false
    t.index ["betfair_market_type_id"], name: "index_betfair_runner_types_on_betfair_market_type_id"
    t.index ["name"], name: "index_betfair_runner_types_on_name"
  end

  create_table "calendars", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "sport_id"
    t.string "name"
    t.index ["sport_id"], name: "index_calendars_on_sport_id"
  end

  create_table "competitions", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "sport_id", null: false
    t.integer "betfair_id", null: false
    t.boolean "active", default: false, null: false
    t.string "region", null: false
    t.bigint "division_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["division_id"], name: "index_competitions_on_division_id"
    t.index ["sport_id"], name: "index_competitions_on_sport_id"
  end

  create_table "divisions", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.integer "odds_numerator", default: 8, null: false
    t.integer "odds_denominator", default: 1, null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "scottish", default: false, null: false
    t.bigint "calendar_id"
    t.index ["calendar_id"], name: "index_divisions_on_calendar_id"
  end

  create_table "football_divisions", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "division_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "football_data_code", limit: 3
    t.string "bbc_slug", limit: 30
    t.string "rapid_api_country"
    t.string "rapid_api_name"
    t.index ["division_id"], name: "fk_rails_f1a35b4a06"
  end

  create_table "market_price_times", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "time", null: false
    t.datetime "created_at"
    t.integer "market_prices_count", default: 0, null: false
    t.index ["time"], name: "index_market_price_times_on_time_and_bet_market_id"
  end

  create_table "market_prices", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "market_runner_id"
    t.decimal "back1price", precision: 7, scale: 3
    t.decimal "lay1price", precision: 7, scale: 3
    t.decimal "back2price", precision: 7, scale: 3
    t.decimal "lay2price", precision: 7, scale: 3
    t.decimal "back3price", precision: 7, scale: 3
    t.decimal "lay3price", precision: 7, scale: 3
    t.decimal "back1amount", precision: 9, scale: 2
    t.decimal "lay1amount", precision: 9, scale: 2
    t.decimal "back2amount", precision: 9, scale: 2
    t.decimal "lay2amount", precision: 9, scale: 2
    t.decimal "back3amount", precision: 9, scale: 2
    t.decimal "lay3amount", precision: 9, scale: 2
    t.bigint "market_price_time_id", null: false
    t.string "status", limit: 20, default: "ACTIVE", null: false
    t.decimal "last_traded_price", precision: 9, scale: 2
    t.index ["market_price_time_id", "market_runner_id"], name: "market_prices_price_time_runner", unique: true
    t.index ["market_price_time_id"], name: "index_market_prices_on_market_price_time_id"
    t.index ["market_runner_id"], name: "market_prices_market_runner_id"
  end

  create_table "market_runners", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "bet_market_id", null: false
    t.integer "selectionId", null: false
    t.string "description", null: false
    t.decimal "handicap", precision: 5, scale: 2
    t.integer "asianLineId"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "sortorder"
    t.integer "market_prices_count", default: 0
    t.integer "betfair_runner_type_id", null: false
    t.index ["bet_market_id"], name: "index_market_runners_on_bet_market_id"
    t.index ["betfair_runner_type_id"], name: "index_market_runners_on_betfair_runner_type_id"
    t.index ["description", "bet_market_id", "handicap"], name: "index_runners_on_desc_bet_market_handicap", unique: true
  end

  create_table "match_teams", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "match_teams_match_id_fk"
    t.index ["team_id"], name: "match_teams_team_id_fk"
  end

  create_table "matches", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "division_id", null: false
    t.datetime "kickofftime", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "actual_start_time"
    t.integer "half_time_duration", default: 900
    t.string "type", null: false
    t.datetime "endtime", null: false
    t.string "name", null: false
    t.boolean "live_priced", default: false, null: false
    t.bigint "venue_id", null: false
    t.integer "bet_markets_count", default: 0
    t.bigint "season_id"
    t.integer "market_prices_count", default: 0, null: false
    t.date "date", null: false
    t.datetime "deleted_at"
    t.integer "betfair_event_id"
    t.index ["betfair_event_id", "deleted_at"], name: "index_matches_on_betfair_event_id_and_deleted_at", unique: true
    t.index ["deleted_at"], name: "index_matches_on_deleted_at"
    t.index ["division_id"], name: "index_matches_on_division_id"
    t.index ["kickofftime"], name: "index_matches_on_kickofftime"
    t.index ["live_priced"], name: "index_matches_on_live_priced"
    t.index ["season_id"], name: "index_matches_on_season_id"
    t.index ["venue_id"], name: "matches_venue_id_fk"
  end

  create_table "results", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.integer "homescore", null: false
    t.integer "awayscore", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "half_time_home_score"
    t.integer "half_time_away_score"
    t.index ["match_id"], name: "index_results_on_match_id", unique: true
  end

  create_table "scorers", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "match_id"
    t.bigint "team_id"
    t.string "name"
    t.integer "goaltime"
    t.boolean "penalty"
    t.boolean "owngoal"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["match_id"], name: "index_scorers_on_match_id"
    t.index ["team_id"], name: "fk_rails_061125b6df"
  end

  create_table "seasons", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.date "startdate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "online", default: true
    t.bigint "calendar_id"
    t.index ["calendar_id"], name: "index_seasons_on_calendar_id"
  end

  create_table "sports", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "betfair_events_count", default: 0, null: false
    t.integer "betfair_sports_id", null: false
    t.integer "expiry_time_in_minutes", default: 60, null: false
    t.boolean "active", default: false, null: false
    t.string "match_type", null: false
    t.index ["betfair_events_count"], name: "index_sports_on_events_count"
    t.index ["name"], name: "index_sports_on_name"
  end

  create_table "team_divisions", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "division_id", null: false
    t.integer "season_id", null: false
    t.index ["division_id"], name: "fk_rails_f6e183de12"
    t.index ["team_id", "division_id", "season_id"], name: "index_team_divisions_on_team_id_and_division_id_and_season_id", unique: true
  end

  create_table "team_names", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "team_id"
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["team_id"], name: "fk_rails_5c2c057ba9"
  end

  create_table "team_total_configs", charset: "utf8mb3", force: :cascade do |t|
    t.integer "count"
    t.integer "threshold"
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "team_totals", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "team_id"
    t.integer "count"
    t.integer "total_goals"
    t.integer "goals_for"
    t.integer "goals_against"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "match_id", null: false
    t.index ["count"], name: "index_team_totals_on_count"
    t.index ["match_id"], name: "index_team_totals_on_match_id"
    t.index ["team_id"], name: "index_team_totals_on_team_id"
    t.index ["total_goals"], name: "index_team_totals_on_total_goals"
  end

  create_table "teams", charset: "utf8mb3", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "sport_id"
    t.index ["sport_id"], name: "fk_rails_11a3a42f5f"
  end

  create_table "trades", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "market_runner_id"
    t.decimal "price", precision: 6, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "size", precision: 6, scale: 2, null: false
    t.string "side", limit: 1, null: false
    t.index ["market_runner_id"], name: "fk_rails_baf8bd2cd8"
  end

  create_table "valuers", charset: "utf8mb3", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "basket_items", "baskets"
  add_foreign_key "basket_items", "market_runners"
  add_foreign_key "basket_rule_items", "basket_rules"
  add_foreign_key "basket_rule_items", "betfair_runner_types"
  add_foreign_key "basket_rules", "sports"
  add_foreign_key "baskets", "basket_rules"
  add_foreign_key "baskets", "matches"
  add_foreign_key "bet_markets", "betfair_market_types"
  add_foreign_key "bet_markets", "matches"
  add_foreign_key "betfair_market_types", "sports"
  add_foreign_key "betfair_runner_types", "betfair_market_types"
  add_foreign_key "football_divisions", "divisions"
  add_foreign_key "market_prices", "market_price_times"
  add_foreign_key "market_prices", "market_runners"
  add_foreign_key "market_runners", "bet_markets"
  add_foreign_key "match_teams", "matches"
  add_foreign_key "match_teams", "teams"
  add_foreign_key "matches", "divisions"
  add_foreign_key "matches", "teams", column: "venue_id"
  add_foreign_key "results", "matches"
  add_foreign_key "scorers", "matches"
  add_foreign_key "scorers", "teams"
  add_foreign_key "team_divisions", "divisions"
  add_foreign_key "team_divisions", "teams"
  add_foreign_key "team_names", "teams"
  add_foreign_key "team_totals", "matches"
  add_foreign_key "team_totals", "teams"
  add_foreign_key "teams", "sports"
  add_foreign_key "trades", "market_runners"
end

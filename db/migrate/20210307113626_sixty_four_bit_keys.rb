# frozen_string_literal: true

#
# $Id$
#
class SixtyFourBitKeys < ActiveRecord::Migration[5.2]
  TABLES = [
    {
      tables: {
        parent_path_id: %i[menu_paths menu_sub_paths].freeze,
        menu_path_id: [:menu_sub_paths].freeze,
      }.freeze,
      name: :menu_paths,
    }.freeze,
    {
      tables: { betfair_market_type_id: %i[bet_markets betfair_runner_types].freeze }.freeze,
      name: :betfair_market_types,
    }.freeze,
    {
      tables: { bet_market_id: %i[market_price_times market_runners].freeze }.freeze,
      name: :bet_markets,
    }.freeze,
    {
      tables: { match_id: %i[baskets bet_markets team_totals match_teams results scorers].freeze }.freeze,
      name: :matches,
    }.freeze,
    {
      tables: { division_id: %i[matches football_divisions team_divisions menu_paths].freeze }.freeze,
      name: :divisions,
    }.freeze,
    {
      tables: { betfair_runner_type_id: [:basket_rule_items].freeze }.freeze,
      name: :betfair_runner_types,
    }.freeze,
    {
      tables: { basket_id: [:basket_items].freeze }.freeze,
      name: :baskets,
    }.freeze,
    {
      tables: { team_id: %i[match_teams team_totals team_names team_divisions scorers].freeze,
                venue_id: [:matches] }.freeze,
      name: :teams,
    }.freeze,
    {
      tables: { sport_id: %i[teams basket_rules betfair_market_types divisions menu_paths].freeze }.freeze,
      name: :sports,
    }.freeze,
    {
      tables: { market_runner_id: %i[market_prices trades basket_items].freeze }.freeze,
      name: :market_runners,
    }.freeze,
    {
      tables: { team_name_id: [].freeze }.freeze,
      name: :team_names,
    }.freeze,
    {
      tables: { valuer_id: [].freeze }.freeze,
      name: :valuers,
    }.freeze,
    {
      tables: { trade_id: [].freeze }.freeze,
      name: :trades,
    }.freeze,
    {
      tables: { team_total_id: [].freeze }.freeze,
      name: :team_totals,
    }.freeze,
    {
      tables: { team_total_config_id: [].freeze }.freeze,
      name: :team_total_configs,
    }.freeze,
    {
      tables: { team_division_id: [].freeze }.freeze,
      name: :team_divisions,
    }.freeze,
    {
      tables: { scorer_id: [].freeze }.freeze,
      name: :scorers,
    }.freeze,
    {
      tables: { result_id: [].freeze }.freeze,
      name: :results,
    }.freeze,
    {
      tables: { login_id: [].freeze }.freeze,
      name: :logins,
    }.freeze,
    {
      tables: { menu_sub_path_id: [].freeze }.freeze,
      name: :menu_sub_paths,
    }.freeze,
    {
      tables: { football_season_id: [].freeze }.freeze,
      name: :football_seasons,
    }.freeze,
    {
      tables: { football_division_id: [].freeze }.freeze,
      name: :football_divisions,
    }.freeze,
    {
      tables: { basket_rule_item_id: [].freeze }.freeze,
      name: :basket_rule_items,
    }.freeze,
    {
      tables: { market_price_id: [].freeze }.freeze,
      name: :market_prices,
    }.freeze,
    {
      tables: { basket_item_id: [].freeze }.freeze,
      name: :basket_items,
    }.freeze,
    {
      tables: { market_price_time_id: [:market_prices].freeze }.freeze,
      name: :market_price_times,
    }.freeze,
    {
      tables: { match_team_id: [].freeze }.freeze,
      name: :match_teams,
    }.freeze,
    {
      tables: { basket_rule_id: %i[basket_rule_items baskets].freeze }.freeze,
      name: :basket_rules,
    }.freeze,
  ].freeze

  def up
    TABLES.each do |table_data|
      table_data[:tables].each do |id_column_name, table_list|
        table_list.each do |table_name|
          remove_foreign_key table_name, column: id_column_name
          change_column table_name, id_column_name, :bigint
        end
      end

      change_column table_data[:name], :id, :bigint, unique: true, null: false, auto_increment: true

      table_data[:tables].each do |id_column_name, table_list|
        table_list.each do |table_name|
          add_foreign_key table_name, table_data[:name], column: id_column_name
        end
      end
    end
  end

  def down
    TABLES.reverse_each do |table_data|
      table_data[:tables].each do |_id_column_name, table_list|
        table_list.each do |table_name|
          remove_foreign_key table_name, table_data[:name]
        end
      end

      change_column table_data[:name], :id, :integer, unique: true, null: false, auto_increment: true

      table_data[:tables].each do |id_column_name, table_list|
        table_list.each do |table_name|
          change_column table_name, id_column_name, :integer
          add_foreign_key table_name, table_data[:name], column: id_column_name
        end
      end
    end
  end
end

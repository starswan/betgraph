# frozen_string_literal: true

#
# $Id$
#
class BetMarketToMarketTypes < ActiveRecord::Migration[5.2]
  TABLES = {
    betfair_market_types: [:bet_markets, :betfair_runner_types].freeze,
    matches: [:results, :scorers].freeze,
    bet_markets: [:market_price_times].freeze,
    divisions: [:matches, :football_divisions, :team_divisions, :menu_paths].freeze,
    betfair_runner_types: [:basket_rule_items].freeze,
    basket_rules: [:basket_rule_items].freeze,
    baskets: [:basket_items].freeze,
    sports: [:teams, :basket_rules, :betfair_market_types, :divisions, :menu_paths].freeze,
    market_runners: [:market_prices, :trades, :basket_items].freeze,
  }.freeze

  def change
    TABLES.each do |dest, sources|
      sources.each { |s| add_foreign_key s, dest }
    end
  end
end

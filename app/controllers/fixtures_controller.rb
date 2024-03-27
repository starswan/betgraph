# frozen_string_literal: true

class FixturesController < ApplicationController
  before_action :load_season

  # show table at season start with no games played
  def index
    @date = @all_matches.first.kickofftime.to_date
    @matches = Match.none
    @fixtures = @priced_matches.played_on(@date)
    @league_tables = @fixtures.group_by(&:division_id).values.map { |matches| LeagueTable.new(matches) }
  end

  # show table for specific date
  def show
    @date = Date.parse(params.fetch(:id))
    @matches = @all_matches.where("kickofftime <= ?", @date)
    @fixtures = @priced_matches.played_on(@date)
    @league_tables = @fixtures.group_by(&:division_id).values.map { |matches| LeagueTable.new(matches) }
  end

private

  def load_season
    @season = Season.find(params.fetch(:season_id))
    all_matches = Match
                    .includes(:result, teams: :team_names).order(:kickofftime)
                    .where(season: @season)
    without_results = all_matches.where.missing(:result)
    @all_matches = all_matches.where.not(id: without_results.map(&:id))
    @priced_matches = @all_matches.with_prices
    @seasons = Season.find(Match.with_prices.select(:season_id).distinct.map(&:season_id)).sort_by(&:startdate)

    @divisions = Division.find @all_matches.map(&:division_id).uniq
  end
end

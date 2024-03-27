# frozen_string_literal: true

module Divisions
  class FixturesController < ApplicationController
    before_action :load_season

    # show table at season start with no games played
    def index
      @date = @all_matches.first.kickofftime.to_date
      @matches = Match.none
      load_teams
    end

    # show table for specific date
    def show
      @date = Date.parse(params.fetch(:id))
      @matches = @all_matches.where("kickofftime <= ?", @date)
      load_teams
    end

  private

    def load_teams
      @fixtures = @all_matches.played_on(@date)
      @league_table = LeagueTable.new(@matches)
    end

    def load_season
      @season = Season.find(params.fetch(:season_id))
      @division = Division.find(params.fetch(:division_id))
      all_matches = Match
                      .includes(:result, teams: :team_names).order(:kickofftime)
                      .where(division: @division, season: @season)
      without_results = all_matches.where.missing(:result)
      @all_matches = all_matches.where.not(id: without_results.map(&:id))
      @priced_matches = @all_matches.with_prices
      @seasons = Season.find(Match.where(division: @division).with_prices.select(:season_id).distinct.map(&:season_id)).sort_by(&:startdate)
      @divisions = Division.find Match.where(division: @division.sport.divisions,
                                             season: @season.calendar.sport.seasons.starting_within(@season.startdate, 1.month))
                                      .with_prices.select(:division_id).distinct.map(&:division_id)
    end
  end
end

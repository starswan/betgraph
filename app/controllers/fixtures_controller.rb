# frozen_string_literal: true

class FixturesController < ApplicationController
  before_action :load_season

  # show current table
  def index
    @date = @all_matches.first.kickofftime
    @matches = Match.none
    @fixtures = @all_matches.played_on(@date)
    load_teams
  end

  # show table for specific date
  def show
    @date = Date.parse(params.fetch(:id))
    @matches = @all_matches.where("kickofftime <= ?", @date)
    @fixtures = @all_matches.played_on(@date)
    load_teams
  end

private

  def load_teams
    teams = @all_matches.map(&:teams).flatten.uniq
    @rows = teams.map { |team| LeagueTableRow.new(team, @matches.select { |m| m.teams.include?(team) }) }.sort_by(&:ordering)
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

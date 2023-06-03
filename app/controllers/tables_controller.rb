# frozen_string_literal: true

# controller for League Tables nested beneath division and seasons
class TablesController < ApplicationController
  before_action :load_season

  # show current table
  def index
    @matches = @all_matches
    load_teams
  end

  # show table for specific date
  def show
    @date = Date.parse(params.fetch(:id))
    @matches = @all_matches.where("kickofftime <= ?", @date + 1.day)
    load_teams
  end

private

  def load_teams
    teams = @matches.map(&:teams).flatten.uniq
    @rows = teams.map { |team| LeagueTableRow.new(team, @matches.select { |m| m.teams.include?(team) }) }
  end

  def load_season
    @season = Season.find(params.fetch(:season_id))
    @division = Division.find(params.fetch(:division_id))
    all_matches = Match
                    .includes(:result, teams: :team_names).order(:kickofftime)
                    .where(division_id: @division.id, season_id: @season.id)
    excluded = all_matches.where.missing(:result)
    @all_matches = all_matches.where.not(id: excluded.map(&:id))
    @seasons = @division.seasons.where("startdate < ?", Time.zone.today)
  end
end

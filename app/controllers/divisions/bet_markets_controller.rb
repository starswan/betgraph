# frozen_string_literal: true

module Divisions
  class BetMarketsController < ApplicationController
    before_action :load_fixture, :load_season

    # show table at season start with no games played
    def index
      @matches = Match.none
      load_teams
      @bet_markets = bet_markets.full_time
    end

    def half_time
      @bet_markets = bet_markets.half_time
      load_teams
    end

  private

    def bet_markets
      BetMarket.includes(market_runners: { market_prices: :market_price_time }).where(match: @fixture).active_status
    end

    def load_teams
      @fixtures = @all_matches.played_on(@date)
    end

    def load_season
      all_matches = Match
                      .includes(:result, teams: :team_names).order(:kickofftime)
                      .where(division: @division, season: @season)
      without_results = all_matches.where.missing(:result)
      @all_matches = all_matches.where.not(id: without_results.map(&:id))
      @seasons = Season.find(Match.where(division: @division).with_prices.select(:season_id).distinct.map(&:season_id)).sort_by(&:startdate)
      @divisions = Division.find Match.where(division: @division.sport.divisions,
                                             season: @season.calendar.sport.seasons.starting_within(@season.startdate, 1.month))
                                      .with_prices.select(:division_id).distinct.map(&:division_id)
    end

    def load_fixture
      @season = Season.find(params.fetch(:season_id))
      @division = Division.find(params.fetch(:division_id))
      @fixture = Match.includes({ division: { calendar: :sport } }, :result, :scorers).find_by! id: params[:fixture_id]
      @date = @fixture.kickofftime.to_date
    end
  end
end

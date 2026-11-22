# frozen_string_literal: true

#
# $Id$
#
module Football
  class DivisionsController < ApplicationController
    # GET /football/divisions
    def index
      @sport = Sport.find_by! name: "Soccer"
      calendars = @sport.calendars
      @divisions = Division.where(calendar: calendars).order("active desc, name")
    end

    # GET /football/divisions/1
    def show
      @sport = Sport.find_by! name: "Soccer"
      @division = Division.find(params[:id])
      @seasons = Season.find(Match.where(division: @division).select(:season_id).distinct.map(&:season_id)).sort_by(&:startdate)
      @priced_seasons = @seasons.select { |s| s.matches.where(division: @division).with_prices.count.positive? }
    end
  end
end

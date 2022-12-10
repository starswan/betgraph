# frozen_string_literal: true

#
# $Id$
#
module Sports
  class MatchesController < ApplicationController
    def index
      @sport = Sport.find params[:sport_id]
      offset = params[:offset] || 0
      limit = params[:limit] || 15
      @order = params[:order] || :kickofftime
      @direction = params[:direction] || "desc"
      @offset = offset.to_i
      @limit = limit.to_i
      @priced_only = params.key?(:priced_only) ? params[:priced_only] : "true"
      matches = Match.includes(:scorers, :result, :division, :bet_markets, teams: :team_names).where(division: @sport.divisions)
      if @priced_only == "true"
        matches = matches.with_prices
      end
      # use name as a tie-breaker on sorting to avoid non-determinism
      @matches = matches.offset(@offset).limit(@limit).order({ @order => @direction }.merge(name: :asc))

      respond_to do |format|
        format.html
        format.json { render json: @matches.to_json }
      end
    end
  end
end

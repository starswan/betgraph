# frozen_string_literal: true

#
# $Id$
#
class SoccerMatches::BetMarketsController < ApplicationController
  before_action :load_match
  # GET /soccer_matches/<matchid>/bet_markets
  # GET /soccer_matches/<matchid>/bet_markets.json
  def index
    @bet_markets = load_full_time

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bet_markets }
      format.xml  { render xml: @bet_markets }
    end
  end

  def half_time
    @bet_markets = load_half_time
  end

private

  def load_half_time
    bet_market.half_time.where(match_id: match_id)
  end

  def load_full_time
    bet_market.full_time.where(match_id: match_id)
  end

  def bet_market
    BetMarket.includes({ match: :result },
                       { market_runners: [
                         { market_prices: :market_price_time },
                         { betfair_runner_type: { betfair_market_type: :sport } },
                       ] },
                       :betfair_market_type).by_active_and_name
  end

  def load_match
    @match = Match.find match_id
  end

  def match_id
    params[:soccer_match_id]
  end
end

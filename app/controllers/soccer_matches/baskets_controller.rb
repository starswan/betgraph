# frozen_string_literal: true

#
# $Id$
#
class SoccerMatches::BasketsController < ApplicationController
  before_action :find_basket, only: :destroy

  # GET /baskets
  # GET /baskets.json
  def index
    @match = Match.includes(
      :result,
      :scorers,
      :teams,
      # bet_markets: { market_runners: { market_prices: :market_price_time } },
      bet_markets: { market_runners: :prices },
      division: { calendar: :sport },
      baskets: [{ basket_items: :market_runner }, :basket_rule],
    ).find params[:soccer_match_id]
    @baskets = @match.baskets

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @baskets }
    end
  end

  # DELETE /baskets/1
  # DELETE /baskets/1.json
  def destroy
    @basket.destroy

    respond_to do |format|
      format.html { redirect_to match_baskets_path(@basket.match) }
      format.json { head :no_content }
    end
  end

private

  def find_basket
    @basket = Basket.find params[:id]
  end
end

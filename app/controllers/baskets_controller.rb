# frozen_string_literal: true

#
# $Id$
#
class BasketsController < ApplicationController
  before_action :find_match_from_basket, except: :index

  # GET /baskets
  # GET /baskets.json
  def index
    @match = Match.includes(
      :result,
      bet_markets: { market_runners: :prices },
      division: { calendar: :sport },
      baskets: [:basket_rule, { basket_items: :market_runner }],
    ).find params[:match_id]
    @baskets = @match.baskets

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @baskets }
    end
  end

  # GET /baskets/1
  # GET /baskets/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @basket }
    end
  end

  # DELETE /baskets/1
  # DELETE /baskets/1.json
  def destroy
    @basket.destroy

    respond_to do |format|
      format.html { redirect_to match_baskets_path(@match) }
      format.json { head :no_content }
    end
  end

private

  def find_match_from_basket
    @basket = Basket.find params[:id]
    @match = @basket.match
  end
end

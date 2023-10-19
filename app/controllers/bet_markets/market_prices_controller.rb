# frozen_string_literal: true

#
# $Id$
#
module BetMarkets
  class MarketPricesController < ApplicationController
    before_action :find_bet_market

    def index
      @market_prices = @bet_market.market_runners.map(&:prices).flatten

      respond_to do |format|
        format.html
      end
    end

    # def destroy
    #   @market_price = MarketPrice.find(params[:id])
    #   @market_price.destroy!
    #
    #   respond_to do |format|
    #     format.html { redirect_to bet_market_market_prices_path(@bet_market) }
    #   end
    # end

  private

    def find_bet_market
      @bet_market = BetMarket.includes(market_runners: :prices).find(params[:bet_market_id])
    end
  end
end

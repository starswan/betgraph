# frozen_string_literal: true

#
# $Id$
#
module BetMarkets
  class TradesController < ApplicationController
    before_action :find_bet_market

    # GET /trades
    # GET /trades.xml
    def index
      @trades = @bet_market.trades

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render xml: @trades }
      end
    end

  private

    def find_bet_market
      @bet_market = BetMarket.find params[:bet_market_id]
    end
  end
end

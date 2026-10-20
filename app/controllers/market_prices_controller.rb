# frozen_string_literal: true

#
# $Id$
#
class MarketPricesController < ApplicationController
  FIND_RUNNER_ACTIONS = [:index, :new, :create].freeze
  before_action :find_market_runner, only: FIND_RUNNER_ACTIONS
  before_action :find_market_runner_from_price, except: FIND_RUNNER_ACTIONS

  # GET /market_runners/1//market_prices
  # GET /market_runners/1market_prices.xml
  # GET /market_runners/1/market_prices.json
  def index
    @market_prices = @market_runner.market_prices
  end

  # GET /market_prices/1
  # GET /market_prices/1.xml
  def show
    @market_price = MarketPrice.find(params[:id])
  end

  # GET /market_prices/new
  # GET /market_prices/new.xml
  def new
    @market_price = MarketPrice.new
    @market_price.market_runner = @market_runner
  end

  # POST /market_prices
  # POST /market_prices.xml
  def create
    @market_price = @market_runner.market_prices.new(market_price_params)

    if @market_price.save
      flash[:notice] = "MarketPrice was successfully created."
      redirect_to(@market_price)
    else
      render action: "new"
    end
  end

  # DELETE /market_prices/1
  # DELETE /market_prices/1.xml
  def destroy
    @market_price = MarketPrice.find(params[:id])
    @market_price.destroy

    redirect_to market_runner_market_prices_path(@market_runner)
  end

private

  def market_price_params
    params.require(:market_price).permit(:market_price_time_id,
                                         :status,
                                         :back1price, :lay1price,
                                         :back2price, :lay2price,
                                         :back3price, :lay3price,
                                         :back1amount, :lay1amount,
                                         :back2amount, :lay2amount,
                                         :back3amount, :lay3amount)
  end

  def find_market_runner
    @market_runner = MarketRunner.find params[:market_runner_id]
  end

  def find_market_runner_from_price
    price = MarketPrice.find params[:id]
    @market_runner = price.market_runner
  end
end

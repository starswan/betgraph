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

    respond_to do |format|
      format.xml  { render xml: @market_prices }
      format.json { render @market_prices.to_json }
    end
  end

  # GET /market_prices/1
  # GET /market_prices/1.xml
  def show
    @market_price = MarketPrice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @market_price }
    end
  end

  # GET /market_prices/new
  # GET /market_prices/new.xml
  def new
    # @market_price = MarketPrice.new
    # @market_price.market_runner = @market_runner
    @market_price = Price.new market_runner: @market_runner

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @market_price }
    end
  end

  # POST /market_prices
  # POST /market_prices.xml
  def create
    params = market_price_params
    @market_price = @market_runner.prices.new(params
      .merge(created_at: MarketPriceTime.find(params[:market_price_time_id]).time))

    respond_to do |format|
      if @market_price.save
        flash[:notice] = "MarketPrice was successfully created."
        format.html { redirect_to(market_runner_path(@market_runner)) }
        format.xml  { render xml: @market_price, status: :created, location: @market_price }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @market_price.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /market_prices/1
  # DELETE /market_prices/1.xml
  def destroy
    @market_price = MarketPrice.find(params[:id])
    @market_price.destroy

    respond_to do |format|
      format.html { redirect_to market_runner_market_prices_path(@market_runner) }
      format.xml  { head :ok }
    end
  end

private

  def market_price_params
    # params.require(:market_price).permit(:market_price_time_id,
    #                                      :status,
    #                                      :back1price, :lay1price,
    #                                      :back2price, :lay2price,
    #                                      :back3price, :lay3price,
    #                                      :back1amount, :lay1amount,
    #                                      :back2amount, :lay2amount,
    #                                      :back3amount, :lay3amount)
    params.require(:market_price).permit :market_price_time_id,
                                         :back_price, :back_amount, :depth, :lay_price, :lay_amount
  end

  def find_market_runner
    @market_runner = MarketRunner.find params[:market_runner_id]
  end

  def find_market_runner_from_price
    price = MarketPrice.find params[:id]
    @market_runner = price.market_runner
  end
end

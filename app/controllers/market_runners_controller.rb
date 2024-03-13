#
# $Id$
#
class MarketRunnersController < ApplicationController
  FIND_EVENT_ACTIONS = [:index, :new, :create].freeze
  before_action :find_market, only: FIND_EVENT_ACTIONS
  before_action :find_market_from_runner, except: FIND_EVENT_ACTIONS

  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :semi_verify_authenticity_token, only: [:create]

  # GET /market_runners
  # GET /market_runners.xml
  def index
    market = params[:bet_market_id]
    runnertype = params[:betfair_runner_type_id]
    @ymax = params[:ymax] || "auto"
    if market
      @bet_market = BetMarket.includes(market_runners: { market_prices: :market_price_time }).find market
      @market_runners = @bet_market.market_runners
    elsif runnertype
      @market_runners = MarketRunner.where(betfair_runner_type_id: runnertype).order(:sortorder)
    else
      @market_runners = MarketRunner.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @market_runners }
    end
  end

  # GET /market_runners/1
  # GET /market_runners/1.xml
  def show
    @market_runner = MarketRunner.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @market_runner }
    end
  end

  # GET /market_runners/new
  # GET /market_runners/new.xml
  def new
    @market_runner = @bet_market.market_runners.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @market_runner }
    end
  end

  # GET /market_runners/1/edit
  def edit
    @market_runner = MarketRunner.find(params[:id])
  end

  # POST /market_runners
  # POST /market_runners.xml
  def create
    @market_runner = @bet_market.market_runners.new(market_runner_params)

    respond_to do |format|
      if @market_runner.save
        MakeBasketItemsJob.perform_later @market_runner
        flash[:notice] = "MarketRunner was successfully created."
        format.html { redirect_to(@market_runner) }
        format.json { render json: @market_runner, status: :created, location: @market_runner }
      else
        format.html { render action: "new" }
        format.json { render json: @market_runner.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /market_runners/1
  # PUT /market_runners/1.xml
  def update
    @market_runner = MarketRunner.find(params[:id])

    respond_to do |format|
      if @market_runner.update(market_runner_params)
        flash[:notice] = "MarketRunner was successfully updated."
        format.html { redirect_to(@market_runner) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @market_runner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /market_runners/1
  # DELETE /market_runners/1.xml
  def destroy
    @market_runner = MarketRunner.find(params[:id])
    # removing a runner invalidates the whole market
    @market_runner.bet_market.destroy
    DestroyObjectJob.perform_later @market_runner.bet_market

    respond_to do |format|
      format.html { redirect_to(bet_market_market_runners_path(@bet_market)) }
      format.xml  { head :ok }
    end
  end

  def beton; end

private

  def market_runner_params
    params.require(:market_runner).permit(:selectionId, :asianLineId, :handicap, :description, :sortorder)
  end

  def find_market
    @bet_market = BetMarket.find(params[:bet_market_id])
  end

  def find_market_from_runner
    @bet_market = MarketRunner.find(params[:id]).bet_market
  end
end

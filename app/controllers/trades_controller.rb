# frozen_string_literal: true

#
# $Id$
#
class TradesController < ApplicationController
  NO_ITEM_ACTIONS = [:index, :new, :create].freeze

  before_action :find_market_runner, only: NO_ITEM_ACTIONS
  before_action :find_market_runner_from_trade, except: NO_ITEM_ACTIONS
  before_action :find_trade, only: [:show, :edit, :update, :destroy]

  # GET /trades
  # GET /trades.xml
  def index
    @trades = @market_runner.trades.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @trades }
    end
  end

  # GET /trades/1
  # GET /trades/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @trade }
    end
  end

  # GET /trades/new
  # GET /trades/new.xml
  def new
    @trade = @market_runner.trades.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @trade }
    end
  end

  # GET /trades/1/edit
  def edit; end

  # POST /trades
  # POST /trades.xml
  def create
    @trade = @market_runner.trades.new(trade_params)

    respond_to do |format|
      if @trade.save
        ExecuteTradeJob.perform_later @trade

        format.html { redirect_to([@market_runner, @trade], notice: "Trade was successfully created.") }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /trades/1
  # PUT /trades/1.xml
  def update
    respond_to do |format|
      if @trade.update(trade_params)
        format.html { redirect_to([@market_runner, @trade], notice: "Trade was successfully updated.") }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /trades/1
  # DELETE /trades/1.xml
  def destroy
    @trade.destroy

    respond_to do |format|
      format.html { redirect_to(market_runner_trades_path(@market_runner)) }
    end
  end

private

  def find_market_runner
    @market_runner = MarketRunner.find params[:market_runner_id]
  end

  def find_market_runner_from_trade
    @market_runner = Trade.find(params[:id]).market_runner
  end

  def trade_params
    params.require(:trade).permit(:size, :price, :side)
  end

  def find_trade
    @trade = Trade.find(params[:id])
  end
end

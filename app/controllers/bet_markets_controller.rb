# frozen_string_literal: true

#
# $Id$
#
class BetMarketsController < ApplicationController
  INDEX_ACTIONS = [:index].freeze
  FIND_EVENT_ACTIONS = [:new, :create].freeze
  before_action :find_match, only: FIND_EVENT_ACTIONS
  before_action :find_match_from_market, except: FIND_EVENT_ACTIONS + INDEX_ACTIONS

  skip_before_action :verify_authenticity_token, only: [:create, :update, :destroy]
  before_action :semi_verify_authenticity_token, only: [:create, :update, :destroy]

  # GET /bet_markets
  # GET /bet_markets.json
  def index
    @match = Match.find(params[:match_id])
    @bet_markets = @match.bet_markets.sort_by { |m| "#{m.active} #{m.name}" }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bet_markets }
      format.xml  { render xml: @bet_markets }
    end
  end

  # GET /bet_markets/1
  # GET /bet_markets/1.json
  def show
    # @bet_market = BetMarket.find params[:id], :include => :market_runners
    @bet_market = BetMarket.find params[:id]

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @bet_market.to_xml(include: :market_runners) }
      format.json { render json: @bet_market }
    end
  end

  # GET /bet_markets/new
  # GET /bet_markets/new.json
  def new
    @bet_market = @match.bet_markets.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @bet_market }
      format.json { render json: @bet_market }
    end
  end

  # GET /bet_markets/1/edit
  def edit
    @bet_market = BetMarket.find(params[:id])
  end

  # POST /bet_markets
  # POST /bet_markets.json
  def create
    @bet_market = @match.bet_markets.new(bet_market_params)

    respond_to do |format|
      if @bet_market.save
        format.html { redirect_to @bet_market, notice: "Bet market was successfully created." }
        format.json { render json: @bet_market, status: :created, location: @bet_market }
        format.xml  { render xml: @bet_market, status: :created, location: @bet_market }
      else
        format.html { render action: "new" }
        format.json { render json: @bet_market.errors, status: :unprocessable_entity }
        format.xml  { render xml: @bet_market.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bet_markets/1
  # PUT /bet_markets/1.json
  def update
    @bet_market = BetMarket.find(params[:id])

    respond_to do |format|
      if @bet_market.update(bet_market_params)
        format.html { redirect_to @bet_market, notice: "Bet market was successfully updated." }
        format.json { head :no_content }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @bet_market.errors, status: :unprocessable_entity }
        format.xml  { render xml: @bet_market.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bet_markets/1
  # DELETE /bet_markets/1.json
  def destroy
    bet_market = BetMarket.find(params[:id])
    bet_market.destroy
    DestroyObjectJob.perform_later bet_market

    respond_to do |format|
      format.html { redirect_to(request.referer || polymorphic_url([@match, :bet_markets])) }
      format.json { head :no_content }
    end
  end

private

  def bet_market_params
    params.require(:bet_market)
          .permit(:marketid, :name,
                  :description, :markettype, :status, :live, :time,
                  :type_variant,
                  :number_of_runners, :total_matched_amount, :active,
                  :live_priced, :match_id,
                  :exchange_id)
  end

  def find_match
    @match = Match.find(params[:match_id])
  end

  def find_match_from_market
    @match = BetMarket.find(params[:id]).match
  end
end

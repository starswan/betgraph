# frozen_string_literal: true

#
# $Id$
#
class BetfairMarketTypesController < ApplicationController
  FIND_SPORT_ACTIONS = [:index].freeze
  before_action :find_sport, only: FIND_SPORT_ACTIONS
  before_action :find_market_type, only: [:show, :edit, :update, :destroy]
  before_action :find_sport_from_market_type, except: FIND_SPORT_ACTIONS

  # GET /betfair_market_types
  # GET /betfair_market_types.xml
  def index
    direction = params[:direction] || "desc"
    @betfair_market_types = @sport.betfair_market_types.order("active desc, updated_at " + direction)

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render xml: @betfair_market_types }
    end
  end

  # GET /betfair_market_types/1
  # GET /betfair_market_types/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render xml: @betfair_market_type }
    end
  end

  # GET /betfair_market_types/1/edit
  def edit; end

  # PUT /betfair_market_types/1
  # PUT /betfair_market_types/1.xml
  def update
    respond_to do |format|
      if @betfair_market_type.update(betfair_market_type_params)
        flash[:notice] = "BetfairMarketType was successfully updated."
        format.html { redirect_to [@betfair_market_type.sport, @betfair_market_type] }
        format.xml { head :ok }
      else
        format.html { render action: "edit" }
        format.xml { render xml: @betfair_market_type.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /betfair_market_types/1
  # DELETE /betfair_market_types/1.xml
  def destroy
    @betfair_market_type.destroy

    respond_to do |format|
      format.html { redirect_to sport_betfair_market_types_path(@sport) }
      format.xml { head :ok }
    end
  end

private

  def betfair_market_type_params
    params.require(:betfair_market_type).permit(:valuer, :param1, :active, :name)
  end

  def find_sport
    @sport = Sport.find params[:sport_id]
  end

  def find_sport_from_market_type
    @sport = @betfair_market_type.sport
  end

  def find_market_type
    @betfair_market_type = BetfairMarketType.find(params[:id])
  end
end

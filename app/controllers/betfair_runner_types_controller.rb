# frozen_string_literal: true

#
# $Id$
#
class BetfairRunnerTypesController < ApplicationController
  before_action :find_market_type
  before_action :find_runner_type, only: [:show, :edit, :update, :destroy]

  # GET /betfair_runner_types
  # GET /betfair_runner_types.xml
  def index
    sort_by = params[:sort_by] ? { params[:sort_by] => :desc } : :name
    @betfair_runner_types = BetfairRunnerType.where("betfair_market_type_id = ?", @betfair_market_type)
                                             .includes(:betfair_market_type).order(sort_by)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @betfair_runner_types }
    end
  end

  # GET /betfair_runner_types/1
  # GET /betfair_runner_types/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @betfair_runner_type }
    end
  end

  # GET /betfair_runner_types/new
  # GET /betfair_runner_types/new.xml
  def new
    @betfair_runner_type = BetfairRunnerType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @betfair_runner_type }
    end
  end

  # GET /betfair_runner_types/1/edit
  def edit; end

  # POST /betfair_runner_types
  # POST /betfair_runner_types.xml
  def create
    @betfair_runner_type = BetfairRunnerType.new(betfair_runner_type_params)
    @betfair_runner_type.betfair_market_type = @betfair_market_type

    respond_to do |format|
      if @betfair_runner_type.save
        flash[:notice] = "BetfairRunnerType was successfully created."
        format.html { redirect_to [@betfair_market_type, @betfair_runner_type] }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /betfair_runner_types/1
  # PUT /betfair_runner_types/1.xml
  def update
    respond_to do |format|
      if @betfair_runner_type.update(betfair_runner_type_params)
        flash[:notice] = "BetfairRunnerType was successfully updated."
        format.html { redirect_to([@betfair_market_type, @betfair_runner_type]) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /betfair_runner_types/1
  # DELETE /betfair_runner_types/1.xml
  def destroy
    @betfair_runner_type.destroy

    respond_to do |format|
      format.html { redirect_to betfair_market_type_betfair_runner_types_path(@betfair_market_type) }
      format.xml  { head :ok }
    end
  end

private

  def find_market_type
    @betfair_market_type = BetfairMarketType.find(params[:betfair_market_type_id])
  end

  def betfair_runner_type_params
    params.require(:betfair_runner_type).permit(:name, :betfair_market_type, :runnertype, :runnerhomevalue, :runnerawayvalue)
  end

  def find_runner_type
    @betfair_runner_type = BetfairRunnerType.find(params[:id])
  end
end

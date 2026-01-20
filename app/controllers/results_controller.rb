# frozen_string_literal: true

#
# $Id$
#
class ResultsController < ApplicationController
  NO_MATCH_ACTIONS = [:index].freeze
  FIND_SPORT_ACTIONS = [:new, :create].freeze
  before_action :find_match, only: FIND_SPORT_ACTIONS
  before_action :find_match_from_result, except: FIND_SPORT_ACTIONS + NO_MATCH_ACTIONS
  before_action :find_result, only: [:show, :edit, :update, :destroy]

  # GET /results
  # GET /results.xml
  def index
    date = Date.parse params[:date]
    @results = Match.where("kickofftime >= ? and kickofftime <= ?", date, date + 1.day).map(&:result).compact

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @results }
    end
  end

  # GET /results/1
  # GET /results/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @result }
    end
  end

  # GET /results/new
  # GET /results/new.xml
  def new
    @result = Result.new
    @result.match = @match

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @result }
    end
  end

  # GET /results/1/edit
  def edit; end

  # POST /results
  # POST /results.xml
  def create
    @result = Result.new(result_params)
    @result.match = @match

    respond_to do |format|
      if @result.save
        format.html { redirect_to(@result, notice: "Result was successfully created.") }
        format.xml  { render xml: @result, status: :created, location: @result }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /results/1
  # PUT /results/1.xml
  def update
    respond_to do |format|
      if @result.update(result_params)
        format.html { redirect_to(@result, notice: "Result was successfully updated.") }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /results/1
  # DELETE /results/1.xml
  def destroy
    @result.destroy

    respond_to do |format|
      format.html { redirect_to(results_url) }
      format.xml  { head :ok }
    end
  end

private

  def result_params
    params.require(:result).permit(:match_id, :homescore, :awayscore)
  end

  def find_match
    @match = Match.find params[:match_id]
  end

  def find_match_from_result
    @match = Result.find(params[:id]).match
  end

  def find_result
    @result = Result.find(params[:id])
  end
end

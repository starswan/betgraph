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
  end

  # GET /results/1
  def show; end

  # GET /results/new
  def new
    @result = Result.new
    @result.match = @match
  end

  # GET /results/1/edit
  def edit; end

  # POST /results
  def create
    @result = Result.new(result_params)
    @result.match = @match

    if @result.save
      redirect_to(@result, notice: "Result was successfully created.")
    else
      render action: "new"
    end
  end

  # PUT /results/1
  def update
    if @result.update(result_params)
      redirect_to(@result, notice: "Result was successfully updated.")
    else
      render action: "edit"
    end
  end

  # DELETE /results/1
  def destroy
    @result.destroy

    redirect_to(results_url)
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

# frozen_string_literal: true

#
# $Id$
#
class ScorersController < ApplicationController
  FIND_ACTIONS = [:index, :new, :create].freeze
  before_action :find_parent, only: FIND_ACTIONS
  before_action :find_parent_from_id, except: FIND_ACTIONS

  # GET /scorers
  # GET /scorers.xml
  def index
    @scorers = @match.scorers.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @scorers }
    end
  end

  # GET /scorers/1
  # GET /scorers/1.xml
  def show
    @scorer = Scorer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @scorer }
    end
  end

  # GET /scorers/new
  # GET /scorers/new.xml
  def new
    @scorer = @match.scorers.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @scorer }
    end
  end

  # GET /scorers/1/edit
  def edit
    @scorer = Scorer.find(params[:id])
  end

  # POST /scorers
  # POST /scorers.xml
  def create
    @scorer = @match.scorers.new(scorer_params)

    respond_to do |format|
      if @scorer.save
        format.html { redirect_to(match_scorers_path(@match), notice: "Scorer was successfully created.") }
        format.xml  { render xml: @scorer, status: :created, location: @scorer }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @scorer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /scorers/1
  # PUT /scorers/1.xml
  def update
    @scorer = Scorer.find(params[:id])

    respond_to do |format|
      if @scorer.update(scorer_params)
        format.html { redirect_to(match_scorers_path(@match), notice: "Scorer was successfully updated.") }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @scorer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /scorers/1
  # DELETE /scorers/1.xml
  def destroy
    @scorer = Scorer.find(params[:id])
    @scorer.destroy

    respond_to do |format|
      format.html { redirect_to match_scorers_path(@match) }
      format.xml  { head :ok }
    end
  end

private

  def scorer_params
    params.require(:scorer).permit(:team_id, :name, :goaltime, :penalty, :owngoal)
  end

  def find_parent
    @match = Match.find params[:match_id]
  end

  def find_parent_from_id
    @match = Scorer.find(params[:id]).match
  end
end

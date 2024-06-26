#
# $Id$
#
class MatchesController < ApplicationController
  ALL_ACTIONS = [:future, :active].freeze
  FIND_DIVISION_ACTIONS = [:index, :new, :create].freeze

  before_action :find_division, only: FIND_DIVISION_ACTIONS
  before_action :find_division_from_match, except: FIND_DIVISION_ACTIONS + ALL_ACTIONS
  before_action :sort_only, only: [:index] + ALL_ACTIONS
  before_action :find_match, only: [:show, :edit, :update, :destroy]

  PAGE_SIZE = 15

  # This was for creating via the API which we don't do any more
  # skip_before_action :verify_authenticity_token, only: [:update, :destroy]
  # before_action :semi_verify_authenticity_token, only: [:update, :destroy]

  # GET /matches/future
  def future
    @matches = Match.future
                    .includes([{ teams: :team_names }, :division, :bet_markets])
                    .order("#{@order} #{@direction}")
    render "current"
  end

  # GET /matches/active
  def active
    @matches = Match.activelive.includes({ teams: :team_names }).order("#{@order} #{@direction}")
    render "current"
  end

  # GET /matches
  # GET /matches.xml
  def index
    dateparam = params[:date]
    if dateparam
      date = Date.parse(dateparam)
      @matches = @division.matches.where("kickofftime >= ? and kickofftime <= ?", date, date + 1.day)
                                  .includes(:teams)
                                  .limit(@limit)
                                  .offset(@offset)
                                  .order("#{@order} #{@direction}")
    else
      @priced_only = params[:priced_only]
      matches = Match.includes(:result, :division, :bet_markets, teams: :team_names).where(division: @division)
      if @priced_only
        matches = matches.with_prices
      end
      @matches = matches.offset(@offset).limit(@limit).order({ @order => @direction })
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /matches/1
  # GET /matches/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /matches/1/edit
  def edit
    @allteams = Team.all.includes(:team_names).joins(:team_names).order("team_names.name")
  end

  # PUT /matches/1
  # PUT /matches/1.xml
  def update
    respond_to do |format|
      if @match.update match_params
        format.html { redirect_to(@match, notice: "Match was successfully updated.") }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /matches/1
  # DELETE /matches/1.xml
  def destroy
    @match.destroy

    DestroyObjectJob.perform_later @match

    respond_to do |format|
      format.js   { head :ok }
      format.html { redirect_to @match.division }
    end
  end

private

  def match_params
    params.require(:match)
          .permit(:kickofftime, :name, :type, :endtime, :venue_id, :live_priced)
  end

  def page_only
    @offset = (params[:offset] || 0).to_i
    @limit = (params[:limit] || PAGE_SIZE).to_i
    set_direction
  end

  def sort_only
    @order = params[:order] || :kickofftime
    @offset = (params[:offset] || 0).to_i
    @limit = (params[:limit] || PAGE_SIZE).to_i
    set_direction
  end

  def set_direction
    @direction = params[:direction] || :asc
  end

  def find_division
    @division = Division.find params[:division_id]
  end

  def find_division_from_match
    @division = Match.find(params[:id]).division
  end

  def find_match
    @match = Match.find(params[:id])
  end
end

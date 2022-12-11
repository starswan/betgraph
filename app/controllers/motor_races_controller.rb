# frozen_string_literal: true

#
# $Id$
#
class MotorRacesController < ApplicationController
  ALL_ACTIONS = [:current, :active].freeze
  FIND_DIVISION_ACTIONS = [:index, :new, :create].freeze
  before_action :find_division, only: FIND_DIVISION_ACTIONS
  before_action :find_division_from_match, except: FIND_DIVISION_ACTIONS + ALL_ACTIONS
  before_action :sort_only, only: [:index] + ALL_ACTIONS
  before_action :page_only, only: [:index]
  PAGE_SIZE = 20

  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :semi_verify_authenticity_token, only: [:create]

  # GET /matches/current
  def current
    @matches = Match.where("deleted = ? and endtime >= ?", false, Time.now)
                   .includes(:teams)
                   .order("#{@order} #{@direction}")

    respond_to do |format|
      format.html { render action: :current }
      format.xml  { render xml: @matches }
    end
  end

  # GET /matches/active
  def active
    # events = BetfairEvent.activelive
    # @matches = events.collect { |e| e.match }
    @matches = Match.activelive
    respond_to do |format|
      format.html { render action: :current }
      format.xml  { render xml: @matches }
    end
  end

  # GET /matches
  # GET /matches.xml
  def index
    # @matches = @division.matches.all :include => [:hometeam, :awayteam],
    #                                 :limit => @limit, :offset => @offset,
    #                                 :order => "#{@match_order} #{@direction}"
    dateparam = params[:date]
    if dateparam
      date = Date.parse(dateparam)
      @matches = @division.matches.where("kickofftime >= ? and kickofftime <= ?", date, date + 1.day)
    # :include => :teams,
    # :limit => @limit, :offset => @offset,
    # :order => "#{@order} #{@direction}"
    else
      @matches = @division.matches.includes(:teams).limit(@limit).offset(@offset).order("#{@order} #{@direction}")
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @matches }
    end
  end

  # GET /matches/1
  # GET /matches/1.xml
  def show
    @match = Match.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @match }
    end
  end

  # GET /matches/new
  # GET /matches/new.xml
  def new
    @match = Match.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @match }
    end
  end

  # GET /matches/1/edit
  def edit
    @match = Match.find(params[:id])
  end

  # POST /matches
  # POST /matches.xml
  def create
    @match = @division.matches.new(params[:match])

    respond_to do |format|
      if @match.save
        format.html { redirect_to(@match, notice: "Match was successfully created.") }
        format.xml  { render xml: @match, status: :created, location: @match }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /matches/1
  # PUT /matches/1.xml
  def update
    @match = Match.find(params[:id])

    respond_to do |format|
      if @match.update(params[:match])
        format.html { redirect_to(@match, notice: "Match was successfully updated.") }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /matches/1
  # DELETE /matches/1.xml
  def destroy
    @match = Match.find(params[:id])
    @match.destroy

    DestroyObjectJob.perform_later @match

    respond_to do |format|
      format.js   { render nothing: true }
      format.html { redirect_to @match.division }
      format.xml  { head :ok }
    end
  end

private

  def page_only
    @offset = (params[:offset] || 0).to_i
    @limit = (params[:limit] || PAGE_SIZE).to_i
  end

  def sort_only
    @direction = params[:direction] || :desc
    # @event_order = params[:order] || :starttime
    @order = params[:order] || :kickofftime
  end

  def find_division
    @division = Division.find params[:division_id]
  end

  def find_division_from_match
    @division = Match.find(params[:id]).division
  end
end

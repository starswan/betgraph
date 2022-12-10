# frozen_string_literal: true

#
# $Id$
#
class TennisMatchesController < ApplicationController
  MATCH_ACTIONS = [:show, :edit, :update, :destroy].freeze
  before_action :find_division_from_football_match, only: MATCH_ACTIONS
  before_action :find_division, except: MATCH_ACTIONS

  # GET /soccer_matches
  # GET /soccer_matches.xml
  def index
    @threshold = (params[:threshold] || 11).to_i
    @offset = params[:offset] ? params[:offset].to_i : 0
    @football_matches = football_matches @offset, nil
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render xml: @football_matches }
    end
  end

  # GET /soccer_matches/1
  # GET /soccer_matches/1.xml
  def show
    @offset = params[:offset] ? params[:offset].to_i : 0
    if @offset > 0
      football_matches = football_matches @offset - 1, 3
      @prev_football_match = football_matches[0]
      @next_football_match = football_matches[2] if football_matches.size > 2
    else
      football_matches = football_matches 0, 2
      @next_football_match = football_matches[1] if football_matches.size > 1
    end
    # @football_match = FootballMatch.find(params[:id], :include => { :betfair_soccer_match => {:event => :bet_markets } })
    @football_match = TennisMatch.find(params[:id])
    @matchtime = params[:matchtime].nil? ? 0 : params[:matchtime].to_i

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @football_match }
    end
  end

  # GET /soccer_matches/new
  # GET /soccer_matches/new.xml
  def new
    @football_match = @division.matches.new type: "TennisMatch"
    # @football_match = @football_season.football_matches.new
    # subpathnames = @football_division.menu_path.menu_sub_paths.collect { |msp| msp.sub_path.name }

    # football_division is a division and a base menu_path
    # need to find all events 'under' the menu path

    # matches = BetfairSoccerMatch.all :joins => :event,
    #                                 :order => 'starttime',
    #                                 :conditions => ['events.active = ? and events.menu_path_name in (?)', true, subpathnames]

    # @betfair_soccer_matches = matches.find_all { |bsm| @football_division.football_matches.find_by_betfair_soccer_match_id(bsm.id).nil? }

    # @footie_fixtures = []
    # @footie_fixtures = @football_division.division.footie_fixtures.all(:order => 'date', :conditions => ['date >= ?', @betfair_soccer_matches[0].event.starttime - 1.day]) if @betfair_soccer_matches.size > 0

    # donefixtures = FootballMatch.all.collect { |match| match.footie_fixture_id }
    # @footie_fixtures.reject! { |ff| donefixtures.include? ff }

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @football_match }
    end
  end

  # GET /football_matches/1/edit
  # def edit
  #   @football_match = FootballMatch.find(params[:id])
  # end

  # POST /soccer_matches
  # POST /soccer_matches.xml
  def create
    @match = @division.matches.new(match_params.merge(type: "TennisMatch"))
    # @match.actual_start_time = @football_match.betfair_soccer_match.event.starttime

    respond_to do |format|
      if @match.save
        # Try to create stuff based on what has gone before
        # maybe this should be a background task trigger?
        # @football_division.auto_football_matches
        flash[:notice] = "TennisMatch was successfully created."
        format.html { redirect_to([@division, @match]) }
        format.xml  { render xml: @match, status: :created, location: @match }
      else
        format.html { render action: "new" }
        format.xml  { logger.debug(@match.errors.inspect); render xml: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /football_matches/1
  # PUT /football_matches/1.xml
  def update
    @football_match = TennisMatch.find(params[:id])

    respond_to do |format|
      if @football_match.update(match_params)
        flash[:notice] = "FootballMatch was successfully updated."
        format.html { redirect_to [@season, @football_match] }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @football_match.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /football_matches/1
  # DELETE /football_matches/1.xml
  def destroy
    @football_match.destroy

    respond_to do |format|
      format.html { redirect_to division_matches_path(@division) }
      format.xml  { head :ok }
      format.js { head :ok }
    end
  end

private

  def find_division_from_football_match
    # @football_match = TennisMatch.find(params[:id], :include => :division)
    @football_match = TennisMatch.find(params[:id])
    @division = @football_match.division
  end

  def find_division
    @division = Division.find params[:division_id]
  end

  def football_matches(offset, limit)
    # @division.soccer_matches.all(:include => [{:hometeam => :team_names}, {:awayteam => :team_names}, :division],
    #                              :order => :kickofftime,
    #                              :limit => limit,
    #                              :offset => offset)
    TennisMatch.includes(:division).where(division: @division)
                                 .order(:kickofftime)
                                 .limit(limit)
                                 .offset(offset)
    # include doesn't work here - maybe it needs to be higher up the call chain?
    # @division.soccer_matches.where('event_id is not null').order(:kickofftime).limit(limit).offset(offset).include([{:hometeam => :team_names}, {:awayteam => :team_names}, :division])
  end

  def match_params
    params.require(:match).permit(:hometeam_id, :awayteam_id, :division, :kickofftime, :event, :name, :endtime, :menu_path, :venue, :venue_id, :live_priced)
  end
end

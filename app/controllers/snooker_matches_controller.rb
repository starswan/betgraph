# frozen_string_literal: true

#
# $Id$
#
class SnookerMatchesController < ApplicationController
  ITEMS_PER_PAGE = 10
  MATCH_ACTIONS = [:show, :edit, :update, :destroy].freeze
  before_action :find_standard_params
  before_action :find_division_from_football_match, only: MATCH_ACTIONS
  before_action :find_division, except: MATCH_ACTIONS

  # GET /snooker_matches
  # GET /snooker_matches.xml
  def index
    # @snooker_matches = football_matches @offset, @limit
    @page = params[:page].to_i
    # Page starts at 1!!!
    @offset = (@page - 1) * ITEMS_PER_PAGE
    @snooker_matches = snooker_matches.page(@page).per(ITEMS_PER_PAGE)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @snooker_matches }
    end
  end

  # GET /snooker_matches/1
  # GET /snooker_matches/1.xml
  def show
    if @offset > 0
      matches = football_matches @offset - 1, 3
      @prev_football_match = matches[0]
      @next_football_match = matches[2] if matches.size > 2
    else
      matches = football_matches 0, 2
      @next_football_match = matches[1] if matches.size > 1
    end
    # @snooker_match = FootballMatch.find(params[:id], :include => { :betfair_soccer_match => {:event => :bet_markets } })
    @snooker_match = SnookerMatch.includes(bet_markets: [{ betfair_market_type: :betfair_runner_types }, :market_runners, :market_price_times]).find(params[:id])
    @matchtime = params[:matchtime].nil? ? 0 : params[:matchtime].to_i

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @snooker_match }
    end
  end

  # GET /snooker_matches/new
  # GET /snooker_matches/new.xml
  def new
    @match = @division.snooker_matches.new
    hometeam = @division.sport.teams.new
    awayteam = @division.sport.teams.new
    @match.venue = hometeam
    @match.teams << hometeam
    @match.teams << awayteam
    # @snooker_match = @football_season.football_matches.new
    # subpathnames = @football_division.menu_path.menu_sub_paths.collect { |msp| msp.sub_path.name }

    # football_division is a division and a base menu_path
    # need to find all events 'under' the menu path

    # matches = BetfairSoccerMatch.all :joins => :event,
    #                                 :order => 'starttime',
    #                                 :conditions => ['events.active = ? and events.menu_path_name in (?)', true, subpathnames]

    # @betfair_snooker_matches = matches.find_all { |bsm| @football_division.football_matches.find_by_betfair_soccer_match_id(bsm.id).nil? }

    # @footie_fixtures = []
    # @footie_fixtures = @football_division.division.footie_fixtures.all(:order => 'date', :conditions => ['date >= ?', @betfair_snooker_matches[0].event.starttime - 1.day]) if @betfair_snooker_matches.size > 0

    # donefixtures = FootballMatch.all.collect { |match| match.footie_fixture_id }
    # @footie_fixtures.reject! { |ff| donefixtures.include? ff }

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @match }
    end
  end

  # GET /football_matches/1/edit
  def edit
    @snooker_match = SnookerMatch.find(params[:id])
    @allteams = @snooker_match.division.sport.teams
                    .includes(:team_names).joins(:team_names).order("team_names.name")
  end

  # POST /snooker_matches
  # POST /snooker_matches.xml
  def create
    @match = @division.snooker_matches.new(match_params)
    # @match.actual_start_time = @snooker_match.betfair_soccer_match.event.starttime

    respond_to do |format|
      if @match.save
        # Try to create stuff based on what has gone before
        # maybe this should be a background task trigger?
        # @football_division.auto_football_matches
        # flash[:notice] = 'SoccerMatch was successfully created.'
        format.html { redirect_to([@division, @match], notice: "SnookerMatch was successfully created.") }
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
    respond_to do |format|
      if @snooker_match.update(match_params)
        flash[:notice] = "FootballMatch was successfully updated."
        format.html { redirect_to [@season, @snooker_match] }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @snooker_match.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /snooker_matches/1
  # DELETE /snooker_matches/1.xml
  def destroy
    @snooker_match.destroy

    respond_to do |format|
      format.html { redirect_to division_snooker_matches_path(@division) }
      format.xml  { head :ok }
      format.js { head :ok }
    end
  end

private

  def match_params
    params.require(:snooker_match)
        .permit(:actual_start_time, :half_time_duration, :division, :kickofftime, :event, :name, :type, :endtime, :menu_path, :venue, :venue_id, :live_priced)
  end

  def find_division_from_football_match
    @snooker_match = SnookerMatch.find(params[:id])
    @division = @snooker_match.division
  end

  def find_division
    @division = Division.find params[:division_id]
  end

  def football_matches(offset, limit)
    @division.snooker_matches.includes([{ teams: :team_names }, :division])
        .order(@order)
        .limit(limit)
        .offset(offset)
  end

  def snooker_matches
    @division.snooker_matches.order(@order)
    # include doesn't work here - maybe it needs to be higher up the call chain?
    # @division.snooker_matches.where('event_id is not null').order(:kickofftime).limit(limit).offset(offset).include([{:hometeam => :team_names}, {:awayteam => :team_names}, :division])
  end

  def find_standard_params
    @order = params[:order] || "kickofftime desc"
    @threshold = (params[:threshold] || 11).to_i
    @offset = params[:offset] ? params[:offset].to_i : 0
    @limit = params[:limit] ? params[:limit].to_i : 20
  end
end

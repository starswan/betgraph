# frozen_string_literal: true

#
# $Id$
#
class SoccerMatchesController < ApplicationController
  ITEMS_PER_PAGE = 10
  MATCH_ACTIONS = [:show, :edit, :update, :destroy].freeze
  before_action :find_standard_params
  before_action :find_division_from_football_match, only: MATCH_ACTIONS
  before_action :find_division, except: MATCH_ACTIONS

  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :semi_verify_authenticity_token, only: [:create]

  # GET /soccer_matches
  # GET /soccer_matches.xml
  def index
    @page = params[:page].to_i
    @football_matches = soccer_matches.page(@page).per(ITEMS_PER_PAGE)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @football_matches }
      format.json { render json: @football_matches.to_json }
    end
  end

  # GET /soccer_matches/1
  # GET /soccer_matches/1.xml
  def show
    if @offset > 0
      matches = football_matches @offset - 1, 3
      @prev_football_match = matches[0]
      @next_football_match = matches[2] if matches.size > 2
    else
      matches = football_matches 0, 2
      @next_football_match = matches[1] if matches.size > 1
    end
    @soccer_match = SoccerMatch.includes(
      [
        :teams,
        :scorers,
        { division: { calendar: :sport } },
        :result,
        bet_markets: [
          { betfair_market_type: [:betfair_runner_types, :sport] },
          { market_runners: [{ betfair_runner_type: :betfair_market_type }, :market_prices] },
        ],
      ],
    ).find(params[:id])
    # 0 for nil is exactly what we want here
    @matchtime = params[:matchtime].to_i

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @soccer_match }
    end
  end

  # GET /soccer_matches/new
  # GET /soccer_matches/new.xml
  def new
    @match = @division.matches.new type: SoccerMatch
    hometeam = @division.calendar.sport.teams.new
    awayteam = @division.calendar.sport.teams.new
    @match.venue = hometeam
    @match.teams << hometeam
    @match.teams << awayteam

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @match }
    end
  end

  # GET /football_matches/1/edit
  # def edit
  #   @football_match = FootballMatch.find(params[:id])
  # end

  # POST /soccer_matches
  # POST /soccer_matches.xml
  def create
    @match = @division.matches.new(create_match_params.merge(type: "SoccerMatch"))
    logger.debug "Saving match #{@match.inspect}"
    unless @match.valid?
      # kill off any unplayed match with the same name
      SoccerMatch.where(name: @match.name).where("kickofftime > ?", Time.zone.now).each do |sm|
        sm.destroy!
        DestroyObjectJob.perform_later sm
      end
    end

    respond_to do |format|
      if @match.save
        format.html { redirect_to([@division, @match], notice: "SoccerMatch was successfully created.") }
        format.xml  { render xml: @match, status: :created, location: @match }
        format.json { render json: @match, status: :created }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @match.errors, status: :unprocessable_entity }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /soccer_matches/1
  # PATCH /soccer_matches/1.xml
  def update
    respond_to do |format|
      live_count = SoccerMatch.future.live_priced.count
      if @football_match.update(update_match_params)
        TickleLivePricesJob.perform_later if live_count.zero? && @football_match.live_priced
        flash[:notice] = "SoccerMatch was successfully updated."
        format.html { redirect_to [@season, @football_match] }
        format.xml  { head :ok }
        format.json { render json: @football_match }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @football_match.errors, status: :unprocessable_entity }
        format.json { render json: @football_match.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /soccer_matches/1
  # DELETE /soccer_matches/1.xml
  def destroy
    @football_match.destroy

    DestroyObjectJob.perform_later @football_match

    respond_to do |format|
      format.html { redirect_to division_soccer_matches_path(@division) }
      format.xml  { head :ok }
      format.js   { head :ok }
    end
  end

private

  def create_match_params
    params.require(:soccer_match)
          .permit(:actual_start_time, :half_time_duration, :kickofftime, :event, :name,
                  :endtime, :menu_path, :live_priced, :hometeam_id, :awayteam_id)
  end

  def update_match_params
    params.require(:soccer_match)
          .permit(:actual_start_time, :half_time_duration, :kickofftime, :event, :name,
                  :endtime, :menu_path, :live_priced)
  end

  def find_division_from_football_match
    @football_match = SoccerMatch.find(params[:id])
    @division = @football_match.division
  end

  def find_division
    @division = Division.find params[:division_id]
  end

  def football_matches(offset, limit)
    SoccerMatch.includes([{ teams: :team_names }, :division])
                            .order(@order)
                            .limit(limit)
                            .offset(offset)
  end

  def soccer_matches
    SoccerMatch.where(division: @division).order(@order)
    # include doesn't work here - maybe it needs to be higher up the call chain?
    # @division.soccer_matches.where('event_id is not null').order(:kickofftime).limit(limit).offset(offset).include([{:hometeam => :team_names}, {:awayteam => :team_names}, :division])
  end

  def find_standard_params
    @order = params[:order] || "kickofftime desc"
    @threshold = (params[:threshold] || 11).to_i
    @offset = params[:offset] ? params[:offset].to_i : 0
    @limit = params.fetch(:limit, 20).to_i
  end
end

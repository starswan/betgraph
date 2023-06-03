# frozen_string_literal: true

#
# $Id$
#
class DivisionsController < ApplicationController
  FIND_SPORT_ACTIONS = [:index, :new, :create].freeze
  before_action :find_calendar, only: FIND_SPORT_ACTIONS
  before_action :find_sport_from_division, except: FIND_SPORT_ACTIONS

  # GET /sports/:id/divisions
  # GET /sports/:id/divisions.xml
  def index
    calendars = @calendar.sport.calendars
    @divisions = Division.where(calendar: calendars).order("active desc, name")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @divisions }
    end
  end

  # GET /divisions/1
  # GET /divisions/1.xml
  def show
    @division = Division.find(params[:id])
    @seasons = Season.find(Match.where(division: @division).select(:season_id).distinct.map(&:season_id)).sort_by(&:startdate)
    @priced_seasons = @seasons.select { |s| s.matches.where(division: @division).with_prices.count.positive? }

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @division }
    end
  end

  # GET /sports/:id/divisions/new
  # GET /sports/:id/divisions/new.xml
  def new
    @division = @calendar.divisions.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @division }
    end
  end

  # GET /divisions/1/edit
  def edit
    @division = Division.find(params[:id])
  end

  # POST /divisions
  # POST /divisions.xml
  def create
    @division = @calendar.divisions.create(division_params)

    respond_to do |format|
      if @division.save
        flash[:notice] = "Division was successfully created."
        format.html { redirect_to(@division) }
        format.xml  { render xml: @division, status: :created, location: @division }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @division.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /divisions/1
  # PUT /divisions/1.xml
  def update
    @division = Division.find(params[:id])

    respond_to do |format|
      if @division.update(division_params)
        flash[:notice] = "Division was successfully updated."
        format.html { redirect_to(@division) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @division.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /divisions/1
  # DELETE /divisions/1.xml
  def destroy
    @division = Division.find(params[:id])
    @division.destroy

    respond_to do |format|
      format.html { redirect_to sport_divisions_path(@division.calendar.sport) }
      format.xml  { head :ok }
    end
  end

private

  def division_params
    params.require(:division)
          .permit(:name, :active, :odds_numerator, :odds_denominator, :calendar_id)
  end

  def find_calendar
    @sport = Sport.find params[:sport_id]
    @calendars = @sport.calendars.map { |c| CalendarPresenter.new(c) }
    @calendar = @sport.calendars.first || @sport.calendars.create!(name: "Default")
  end

  def find_sport_from_division
    @sport = Division.find(params[:id]).calendar.sport
    @calendars = @sport.calendars.map { |c| CalendarPresenter.new(c) }
  end
end

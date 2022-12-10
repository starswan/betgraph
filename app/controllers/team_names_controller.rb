# frozen_string_literal: true

#
# $Id$
#
class TeamNamesController < ApplicationController
  FIND_SPORT_ACTIONS = [:index, :new, :create].freeze

  before_action :find_team, only: FIND_SPORT_ACTIONS
  before_action :find_team_from_name, except: FIND_SPORT_ACTIONS

  # GET /team_names
  # GET /team_names.xml
  def index
    @team_names = @team.team_names

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @team_names }
    end
  end

  # GET /team_names/1
  # GET /team_names/1.xml
  def show
    @team_name = TeamName.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @team_name }
    end
  end

  # GET /team_names/new
  # GET /team_names/new.xml
  def new
    @team_name = @team.team_names.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @team_name }
    end
  end

  # GET /team_names/1/edit
  def edit
    # @teams = @team_name.team.sport.teams.all(:include => :team_names).reject { |tm| tm == @team_name.team }.sort_by { |t| t.name }
    @teams = @team_name.team.sport.teams.includes(:team_names).reject { |tm| tm == @team_name.team }.sort_by { |t| t.name }
  end

  # POST /team_names
  # POST /team_names.xml
  def create
    @team_name = @team.team_names.new(team_name_params)

    respond_to do |format|
      if @team_name.save
        format.html { redirect_to([@team, @team_name], notice: "TeamName was successfully created.") }
        format.xml  { render xml: @team_name, status: :created, location: [@team, @team_name] }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @team_name.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /team_names/1
  # PUT /team_names/1.xml
  def update
    respond_to do |format|
      if update_team
        format.html { redirect_to(@team_name.team, notice: "TeamName was successfully updated.") }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @team_name.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /team_names/1
  # DELETE /team_names/1.xml
  def destroy
    @team_name.destroy

    respond_to do |format|
      format.html { redirect_to(team_team_names_url(@team)) }
      format.xml  { head :ok }
    end
  end

private

  def find_team
    @team = Team.find params[:team_id]
  end

  def find_team_from_name
    @team_name = TeamName.find(params[:id])
    @team = @team_name.team
  end

  def team_name_params
    params.require(:team_name).permit(:name)
  end

  def update_team
    @team_name = TeamName.find(params[:id])
    oldteam = @team_name.team
    worked = true
    changes = team_name_params
    if @team_name.update(changes)
      @team_name.team = Team.find @team_name.team_id
      oldteam.matches.each do |match|
        if match.hometeam == oldteam
          match.hometeam = @team_name.team
          worked = worked && match.save
        end
        if match.awayteam == oldteam
          match.awayteam = @team_name.team
          worked = worked && match.save
        end
      end
      oldteam.destroy if oldteam.team_names.size == 0
      worked
    else
      false
    end
  end
end

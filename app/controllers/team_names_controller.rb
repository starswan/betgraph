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
    end
  end

  # GET /team_names/1
  # GET /team_names/1.xml
  def show
    @team_name = TeamName.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /team_names/new
  # GET /team_names/new.xml
  def new
    @team_name = @team.team_names.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /team_names/1/edit
  def edit
    @teams = @team_name.team.sport.teams.includes(:team_names).reject { |tm| tm == @team_name.team }.sort_by(&:name)
  end

  # POST /team_names
  # POST /team_names.xml
  def create
    @team_name = @team.team_names.new(team_name_params)

    respond_to do |format|
      if @team_name.save
        format.html { redirect_to([@team, @team_name], notice: "TeamName was successfully created.") }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /team_names/1
  # PUT /team_names/1.xml
  def update
    respond_to do |format|
      if update_team
        format.html { redirect_to(@team_name.team, notice: "TeamName was successfully updated.") }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /team_names/1
  # DELETE /team_names/1.xml
  def destroy
    @team_name.destroy

    respond_to do |format|
      format.html { redirect_to(team_team_names_url(@team)) }
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
    params.require(:team_name).permit(:name, :team_id)
  end

  def update_team
    @otherteam = Team.find team_name_params.fetch(:team_id)
    worked = false
    Team.transaction do
      @otherteam.team_names.each do |tn|
        tn.team = @team
        tn.save || raise(ActiveRecord::Rollback)
      end
      @otherteam.match_teams.each do |mt|
        mt.team = @team
        mt.save || raise(ActiveRecord::Rollback)
        next unless mt.match.venue == @otherteam

        Match.where(date: mt.match.date, venue: @team).destroy_all
        done = mt.match.update(venue: @team)
        unless done
          logger.warn "Failed to update match #{mt.match.errors.full_messages}"
          raise(ActiveRecord::Rollback)
        end
      end
      @otherteam.reload.destroy
      worked = true
    end
    worked
  end
end

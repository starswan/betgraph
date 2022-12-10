# frozen_string_literal: true

#
# $Id$
#
class TeamsController < ApplicationController
  FIND_SPORT_ACTIONS = [:index, :new, :create].freeze

  before_action :find_sport, only: FIND_SPORT_ACTIONS
  before_action :find_sport_from_team, except: FIND_SPORT_ACTIONS
  before_action :find_teams, only: [:edit, :update]
  before_action :find_team, only: [:show, :edit, :update, :destroy]

  # GET /teams
  # GET /teams.xml
  def index
    sort_by = params[:sort_by].try(:to_sym)
    teams = @sport.teams.includes(:team_names)
    if sort_by
      if sort_by.in? ["created_at"]
        @teams = teams.order(sort_by => :desc)
      else
        @teams = teams.sort_by { |t| t.public_send(sort_by) }
      end
    else
      @teams = teams.sort_by(&:name)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @teams.to_xml(include: :team_names) }
    end
  end

  # GET /teams/1
  # GET /teams/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @team }
    end
  end

  # GET /teams/1/edit
  def edit; end

  # PUT /teams/1
  # PUT /teams/1.xml
  def update
    @otherteam = Team.find params[:other_team][:other_team_id]
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

        other_match = Match.find_by(date: mt.match.date, venue: @team)
        other_match.destroy if other_match
        done = mt.match.update(venue: @team)
        unless done
          logger.warn "Failed to update match #{mt.match.errors.full_messages}"
          raise(ActiveRecord::Rollback)
        end
      end
      # @otherteam.destroy
      worked = true
    end

    respond_to do |format|
      if worked
        format.html { redirect_to([@sport, @team], notice: "Team was successfully updated.") }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.xml
  def destroy
    @team.destroy

    respond_to do |format|
      format.html { redirect_to(request.referer || sport_teams_url(@sport)) }
      format.xml  { head :ok }
    end
  end

private

  def find_sport
    @sport = Sport.find params[:sport_id]
  end

  def find_sport_from_team
    @sport = Team.find(params[:id]).sport
  end

  def find_teams
    # @teams = @sport.teams.all(:include => :team_names).reject { |tm| tm == @team or tm.name.nil? }.sort_by { |t| t.name }
    @teams = @sport.teams.includes(:team_names).reject { |tm| (tm == @team) || tm.name.nil? }.sort_by { |t| t.name }
  end

  def find_team
    @team = Team.find(params[:id])
  end
end

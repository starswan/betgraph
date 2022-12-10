# frozen_string_literal: true

#
# $Id$
#
class MatchTeamsController < ApplicationController
  before_action :find_sport

  # GET /matches/:id/teams
  # GET /matches/:id/teams.xml
  def index
    @teams = @match.teams

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render xml: @teams }
    end
  end

private

  def find_sport
    @match = Match.find params[:match_id]
  end
end

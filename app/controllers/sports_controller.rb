# frozen_string_literal: true

#
# $Id$
#
class SportsController < ApplicationController
  # GET /sports/1
  # GET /sports/1.xml
  def show
    @sport = Sport.find(params[:id])

    respond_to do |format|
      format.html
    end
  end
end

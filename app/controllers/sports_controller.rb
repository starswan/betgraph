# frozen_string_literal: true

#
# $Id$
#
class SportsController < ApplicationController
  # GET /sports
  # GET /sports.xml
  def index
    # @sports = Sport.all :order => 'active desc, betfair_events_count desc, name'
    @sports = Sport.order "active desc, betfair_events_count desc, name"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @sports }
    end
  end

  # GET /sports/1
  # GET /sports/1.xml
  def show
    @sport = Sport.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @sport }
    end
  end

  # GET /sports/1/edit
  def edit
    @sport = Sport.find(params[:id])
  end

  # PUT /sports/1
  # PUT /sports/1.xml
  def update
    @sport = Sport.find(params[:id])

    respond_to do |format|
      if @sport.update(sport_params)
        flash[:notice] = "Sport was successfully updated."
        format.html { redirect_to(@sport) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @sport.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sports/1
  # DELETE /sports/1.xml
  def destroy
    @sport = Sport.find(params[:id])
    @sport.destroy

    respond_to do |format|
      format.html { redirect_to(sports_url) }
      format.xml  { head :ok }
    end
  end

private

  def sport_params
    params.require(:sport)
          .permit :name, :expiry_time_in_minutes, :betfair_sports_id, :active
  end
end

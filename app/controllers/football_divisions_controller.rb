# frozen_string_literal: true

#
# $Id$
#
class FootballDivisionsController < ApplicationController
  # GET /football_divisions
  # GET /football_divisions.xml
  def index
    # @football_divisions = FootballDivision.all(:include => [:division], :order => 'divisions.name')
    @football_divisions = FootballDivision.includes(:division).order("divisions.name")

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /football_divisions/1
  # GET /football_divisions/1.xml
  def show
    @football_division = FootballDivision.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /football_divisions/new
  # GET /football_divisions/new.xml
  def new
    @football_division = FootballDivision.new
    # existing = []
    # FootballDivision.all.each { |fd| existing << fd.division }
    existing = FootballDivision.all.collect(&:division)
    # @divisions = Division.all(:order => 'name', :conditions => ['active = ?', true]).reject { |d| existing.include?(d) }
    @divisions = Division.where("active = ?", true).order("name").reject { |d| existing.include?(d) }
    # @divisions.reject! do |division|
    #   existing.include? division
    # end

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /football_divisions/1/edit
  def edit
    @football_division = FootballDivision.find(params[:id])
  end

  # POST /football_divisions
  # POST /football_divisions.xml
  def create
    @football_division = FootballDivision.new(division_id: params[:division][:division_id], football_data_code: params[:football_division][:football_data_code])

    respond_to do |format|
      if @football_division.save
        flash[:notice] = "FootballDivision was successfully created."
        format.html { redirect_to(@football_division) }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /football_divisions/1
  # PUT /football_divisions/1.xml
  def update
    @football_division = FootballDivision.find(params[:id])

    respond_to do |format|
      if @football_division.update(football_division_params)
        flash[:notice] = "FootballDivision was successfully updated."
        format.html { redirect_to(@football_division) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /football_divisions/1
  # DELETE /football_divisions/1.xml
  def destroy
    @football_division = FootballDivision.find(params[:id])
    @football_division.destroy

    respond_to do |format|
      format.html { redirect_to(football_divisions_url) }
    end
  end

private

  def football_division_params
    params.require(:football_division).permit(:football_data_code)
  end
end

# frozen_string_literal: true

#
# $Id$
#
class MenuPathsController < ApplicationController
  FIND_SPORT_ACTIONS = [:index, :new, :create].freeze
  before_action :find_sport, only: FIND_SPORT_ACTIONS
  before_action :find_sport_from_menu_path, except: FIND_SPORT_ACTIONS

  # GET /menu_paths
  # GET /menu_paths.xml
  def index
    @menu_paths = @sport.top_menu_paths
    respond_to do |format|
      format.html { render layout: "menu_paths" } # show.html.erb
      format.xml  { render xml: @menu_paths }
    end
  end

  # GET /menu_paths/1
  # GET /menu_paths/1.xml
  def show
    @menu_path = MenuPath.find params[:id]

    respond_to do |format|
      format.html { render layout: "menu_paths" } # show.html.erb
      format.xml  { render xml: @menu_path }
    end
  end

  # GET /menu_paths/new
  # GET /menu_paths/new.xml
  def new
    @menu_path = @sport.menu_paths.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @menu_path }
    end
  end

  # GET /menu_paths/1/edit
  def edit
    @divisions = @sport.divisions.order(:name)
    @menu_path = MenuPath.find(params[:id])

    respond_to do |format|
      format.html { render layout: "menu_paths" } # show.html.erb
      format.xml  { render xml: @menu_path }
    end
  end

  # POST /menu_paths
  # POST /menu_paths.xml
  def create
    @menu_path = @sport.menu_paths.new(menu_path_params)

    respond_to do |format|
      if @menu_path.save
        format.html { redirect_to(@menu_path, notice: "MenuPath was successfully created.") }
        format.xml  { render xml: @menu_path, status: :created, location: @menu_path }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @menu_path.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /menu_paths/1
  # PUT /menu_paths/1.xml
  def update
    menu_path_id = params[:id]
    @menu_path = MenuPath.find menu_path_id

    respond_to do |format|
      if @menu_path.update(menu_path_params)
        MakeMenuPathsJob.perform_later @menu_path
        format.html { redirect_to(@menu_path, notice: "MenuPath was successfully updated.") }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @menu_path.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /menu_paths/1
  # DELETE /menu_paths/1.xml
  def destroy
    menu_path_id = params[:id]
    @menu_path = MenuPath.find menu_path_id
    @menu_path.destroy
    MakeMenuPathsJob.perform_later @menu_path.parent_path if @menu_path.parent_path

    respond_to do |format|
      format.html { redirect_to @menu_path.parent_path || @menu_path.sport }
      format.xml  { head :ok }
    end
  end

private

  def menu_path_params
    params.require(:menu_path)
          .permit(:active, :name, :depth, :parent, :parent_path_id, :activeGrandChildren, :activeChildren, :division_id)
  end

  def find_sport
    @sport = Sport.find params[:sport_id]
  end

  def find_sport_from_menu_path
    @sport = MenuPath.find(params[:id]).sport
  end
end

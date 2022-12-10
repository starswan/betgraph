# frozen_string_literal: true

#
# $Id$
#
class BasketRuleItemsController < ApplicationController
  NO_ITEM_ACTIONS = [:index, :new, :create].freeze
  before_action :find_basket_rule, only: NO_ITEM_ACTIONS
  before_action :find_rule_from_item, except: NO_ITEM_ACTIONS
  # GET /basket_items
  # GET /basket_items.xml
  def index
    @basket_items = @basket_rule.basket_rule_items

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @basket_items }
    end
  end

  # GET /basket_items/1
  # GET /basket_items/1.xml
  def show
    @basket_item = BasketRuleItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @basket_item }
    end
  end

  # GET /basket_items/new
  # GET /basket_items/new.xml
  def new
    find_valid_runner_types
    @basket_rule_item = @basket_rule.basket_rule_items.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render xml: @basket_rule_item }
    end
  end

  # GET /basket_items/1/edit
  def edit
    find_valid_runner_types
    @basket_rule_item = BasketRuleItem.find(params[:id])
  end

  # POST /basket_items
  # POST /basket_items.xml
  def create
    @basket_rule_item = @basket_rule.basket_rule_items.new(basket_rule_item_params)

    respond_to do |format|
      if @basket_rule_item.save
        format.html { redirect_to basket_rule_basket_rule_items_path(@basket_rule), notice: "BasketRuleItem was successfully created." }
        format.xml  { render xml: @basket_rule_item, status: :created, location: @basket_rule_item }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @basket_rule_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /basket_items/1
  # PUT /basket_items/1.xml
  def update
    @basket_rule_item = BasketRuleItem.find(params[:id])

    respond_to do |format|
      if @basket_rule_item.update(basket_rule_item_params)
        format.html { redirect_to([@basket_rule, @basket_rule_item], notice: "BasketRuleItem was successfully updated.") }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @basket_rule_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /basket_items/1
  # DELETE /basket_items/1.xml
  def destroy
    @basket_item = BasketRuleItem.find(params[:id])
    @basket_item.destroy

    respond_to do |format|
      format.html { redirect_to(basket_rule_basket_rule_items_path(@basket_rule)) }
      format.xml  { head :ok }
    end
  end

private

  def basket_rule_item_params
    params.require(:basket_rule_item)
          .permit(:weighting, :betfair_runner_type_id, :betfair_runner_type)
  end

  def find_valid_runner_types
    # @runner_types = @sport.betfair_market_types(:include => :betfair_runner_types)
    #                       .where(:active => true).order(:name)
    #                       .collect { |type| type.betfair_runner_types }.flatten!
    @runner_types = BetfairMarketType
                        .where(sport: @sport)
                        .where(active: true).order(:name)
                        .includes(:betfair_runner_types)
                        .collect { |type| type.betfair_runner_types }.flatten!
  end

  def find_basket_rule
    @basket_rule = BasketRule.find params[:basket_rule_id]
    @sport = @basket_rule.sport
  end

  def find_rule_from_item
    @basket_rule = BasketRuleItem.find(params[:id]).basket_rule
    @sport = @basket_rule.sport
  end
end

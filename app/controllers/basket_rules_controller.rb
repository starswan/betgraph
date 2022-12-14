# frozen_string_literal: true

#
# $Id$
#
class BasketRulesController < ApplicationController
  NO_BASKET_ACTIONS = %i[index new create].freeze
  before_action :find_sport, only: NO_BASKET_ACTIONS
  before_action :find_sport_from_basket, except: NO_BASKET_ACTIONS

  # GET /baskets
  # GET /baskets.xml
  def index
    @basket_rules = @sport.basket_rules.order(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @basket_rules }
    end
  end

  # GET /baskets/1
  # GET /baskets/1.xml
  def show
    # @basket_rule = BasketRule.find(params[:id])
    @basket_rule = @sport.basket_rules.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @basket_rule }
    end
  end

  # GET /baskets/new
  # GET /baskets/new.xml
  def new
    # @basket_rule = BasketRule.new
    @basket_rule = @sport.basket_rules.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @basket_rule }
    end
  end

  # GET /baskets/1/edit
  def edit
    # @basket_rule = BasketRule.find(params[:id])
    @basket_rule = @sport.basket_rules.find(params[:id])
  end

  # POST /baskets
  # POST /baskets.xml
  def create
    @basket_rule = @sport.basket_rules.new(basket_rule_params)
    # @basket_rule = BasketRule.new(params[:basket])
    # @basket_rule.sport = @sport

    respond_to do |format|
      if @basket_rule.save
        format.html { redirect_to(basket_rule_basket_rule_items_path(@basket_rule), notice: "Basket Rule was successfully created.") }
        format.xml  { render xml: @basket_rule, status: :created, location: [@sport, @basket_rule] }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @basket_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /baskets/1
  # PUT /baskets/1.xml
  def update
    @basket_rule = @sport.basket_rules.find(params[:id])
    # @basket_rule = BasketRule.find(params[:id])

    respond_to do |format|
      if @basket_rule.update(basket_rule_params)
        format.html { redirect_to(@basket_rule, notice: "Basket Rule was successfully updated.") }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @basket_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /baskets/1
  # DELETE /baskets/1.xml
  def destroy
    @basket_rule = @sport.basket_rules.find(params[:id])
    # @basket_rule = BasketRule.find(params[:id])
    @basket_rule.destroy

    respond_to do |format|
      format.html { redirect_to(sport_basket_rules_path(@basket_rule.sport)) }
      format.xml  { head :ok }
    end
  end

private

  def basket_rule_params
    params.require(:basket_rule)
          .permit(:name, :betfair_runner_type, :count)
  end

  def find_sport
    @sport = Sport.find params[:sport_id]
  end

  def find_sport_from_basket
    @sport = find_basket.sport
  end

  def find_basket
    BasketRule.find params[:id]
  end
end

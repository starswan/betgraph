# frozen_string_literal: true

#
# $Id$
#
class BasketItemsController < ApplicationController
  NO_ITEM_ACTIONS = %i[index new create].freeze
  before_action :find_basket, only: NO_ITEM_ACTIONS
  before_action :find_basket_from_item, except: NO_ITEM_ACTIONS
  # GET /basket_items
  # GET /basket_items.xml
  def index
    @basket_items = @basket.basket_items

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @basket_items }
    end
  end

  # GET /basket_items/1
  # GET /basket_items/1.xml
  def show
    @basket_item = BasketItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @basket_item }
    end
  end

  # GET /basket_items/new
  # GET /basket_items/new.xml
  def new
    @runners = find_valid_runners
    @basket_item = @basket.basket_items.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render xml: @basket_item }
    end
  end

  # GET /basket_items/1/edit
  def edit
    @runners = find_valid_runners
    @basket_item = BasketItem.find(params[:id])
  end

  # POST /basket_items
  # POST /basket_items.xml
  def create
    @basket_item = @basket.basket_items.new basket_item_params

    respond_to do |format|
      if @basket_item.save
        format.html { redirect_to(basket_basket_items_path(@basket), notice: "BasketItem was successfully created.") }
        format.xml  { render xml: @basket_item, status: :created, location: @basket_item }
      else
        @runners = find_valid_runners
        format.html { render action: "new" }
        format.xml  { render xml: @basket_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /basket_items/1
  # PUT /basket_items/1.xml
  def update
    @basket_item = BasketItem.find(params[:id])

    respond_to do |format|
      if @basket_item.update(basket_item_params)
        format.html { redirect_to([@basket, @basket_item], notice: "BasketItem was successfully updated.") }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @basket_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /basket_items/1
  # DELETE /basket_items/1.xml
  def destroy
    BasketItem.find(params[:id]).destroy!

    respond_to do |format|
      format.html { redirect_to basket_basket_items_path(@basket) }
      format.xml  { head :ok }
    end
  end

private

  def find_valid_runners
    BetMarket.includes(:market_runners)
        .where(match: @basket.match, active: true)
        .order(:name)
        .collect(&:market_runners).flatten!
  end

  def find_basket
    @basket = Basket.includes(basket_items: { market_runner: :bet_market }).find params[:basket_id]
  end

  def find_basket_from_item
    @basket = BasketItem.find(params[:id]).basket
  end

  def basket_item_params
    params.require(:basket_item).permit(:weighting, :market_runner_id, :market_runner)
  end
end

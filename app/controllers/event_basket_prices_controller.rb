# frozen_string_literal: true

#
# $Id$
#
class EventBasketPricesController < ApplicationController
  NO_ITEM_ACTIONS = [:index].freeze
  before_action :find_basket, only: NO_ITEM_ACTIONS
  # before_action :find_basket_from_item, :except => NO_ITEM_ACTIONS
  # GET /event_basket_prices
  # GET /event_basket_prices.xml
  def index
    @event_basket_prices = @basket.event_basket_prices

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @event_basket_prices }
    end
  end

private

  def find_basket
    @basket = Basket.find params[:basket_id]
  end
end

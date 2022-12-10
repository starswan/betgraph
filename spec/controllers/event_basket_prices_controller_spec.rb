# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe EventBasketPricesController, type: :controller do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }

  let!(:match) { create(:soccer_match, division: division, baskets: [build(:basket)]) }
  let(:basket) { match.baskets.first }

  it "gets index" do
    get :index, params: { basket_id: basket.id }
    assert_response :success
    expect(assigns(:event_basket_prices)).not_to be_nil
  end
end

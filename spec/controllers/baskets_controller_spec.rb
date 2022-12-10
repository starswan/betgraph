# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe BasketsController, type: :controller do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let!(:amatch) { create(:soccer_match, division: division, baskets: [build(:basket)]) }
  let(:basket) { amatch.baskets.first }

  it "gets index" do
    get :index, params: { match_id: amatch }
    assert_response :success
    expect(assigns(:baskets)).not_to be_nil
  end

  it "shows basket" do
    get :show, params: { id: basket.to_param }
    assert_response :success
  end

  it "destroys basket" do
    expect {
      delete :destroy, params: { id: basket.to_param }
    }.to change(Basket, :count).by(-1)

    assert_redirected_to match_baskets_path(amatch)
  end
end

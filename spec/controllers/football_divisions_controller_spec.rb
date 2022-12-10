# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe FootballDivisionsController, type: :controller do
  before do
    div = create(:division)
    create(:football_division, division: div)
  end

  let(:division) { Division.last }
  let(:football_division) { FootballDivision.last }

  it "gets index" do
    get :index
    assert_response :success
    expect(assigns(:football_divisions)).not_to be_nil
  end

  it "gets new" do
    get :new
    assert_response :success
  end

  it "creates football_division" do
    expect {
      post :create, params: { football_division: { football_data_code: "XXX" }, division: { division_id: division } }
    }.to change(FootballDivision, :count).by(1)

    assert_redirected_to football_division_path(assigns(:football_division))
  end

  it "shows football_division" do
    get :show, params: { id: football_division }
    assert_response :success
  end

  it "gets edit" do
    get :edit, params: { id: football_division }
    assert_response :success
  end

  it "updates football_division" do
    put :update, params: { id: football_division, football_division: { football_data_code: "XXX" } }
    assert_redirected_to football_division_path(assigns(:football_division))
  end

  it "destroys football_division" do
    expect {
      delete :destroy, params: { id: football_division }
    }.to change(FootballDivision, :count).by(-1)

    assert_redirected_to football_divisions_path
  end
end

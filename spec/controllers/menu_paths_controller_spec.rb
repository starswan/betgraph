# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe MenuPathsController, :betfair, type: :controller do
  before do
    create(:sport, menu_paths: [build(:menu_path)], basket_rules: [build(:basket_rule, name: "Rule 1")])
  end

  let(:sport) { Sport.last }
  let(:menu_path) { sport.menu_paths.first }

  it "gets index" do
    get :index, params: { sport_id: sport }
    assert_response :success
  end

  it "gets new" do
    get :new, params: { sport_id: sport }
    assert_response :success
  end

  it "creates menu_path" do
    expect {
      post :create, params: { sport_id: sport, menu_path: { name: "Fred", parent_path_id: menu_path } }
    }.to change(MenuPath, :count).by(1)

    assert_redirected_to menu_path_path(assigns(:menu_path))
  end

  it "does not create menu_path on error" do
    expect {
      post :create, params: { sport_id: sport, menu_path: { name: "", parent_path_id: menu_path } }
    }.to change(MenuPath, :count).by(0)
  end

  it "shows menu_path" do
    get :show, params: { id: menu_path }
    assert_response :success
  end

  it "gets edit" do
    get :edit, params: { id: menu_path }
    assert_response :success
  end

  context "with login" do
    let!(:login) { create(:login) }

    before do
      stub_betfair_login
    end

    it "updates menu_path" do
      put :update, params: { id: menu_path, menu_path: { name: "fgret" } }
      assert_redirected_to menu_path_path(assigns(:menu_path))
    end

    it "does not update menu_path on error" do
      put :update, params: { id: menu_path, menu_path: { name: "" } }
      expect(assigns(:menu_path).errors.full_messages).to eq(["Name can't be blank"])
    end
  end

  it "destroys menu_path" do
    expect {
      delete :destroy, params: { id: menu_path }
    }.to change(MenuPath, :count).by(-1)
  end
end

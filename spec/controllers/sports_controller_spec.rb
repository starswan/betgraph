# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe SportsController, type: :controller do
  render_views

  context "with sport" do
    let(:sport) { create(:sport, calendars: build_list(:calendar, 1, divisions: build_list(:division, 1))) }

    it "shows sport" do
      get :show, params: { id: sport.id }
      assert_response :success
    end
  end

  context "with soccer" do
    let(:sport) { create(:soccer) }

    it "shows sport" do
      get :show, params: { id: sport.id }
      assert_response :success
    end
  end
end

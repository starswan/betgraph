# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe SportsController, type: :controller do
  let!(:sport) { create(:sport) }

  it "shows sport" do
    get :show, params: { id: sport.id }
    assert_response :success
  end
end

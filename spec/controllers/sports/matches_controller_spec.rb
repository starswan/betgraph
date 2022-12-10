# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Sports::MatchesController, type: :controller do
  let(:sport) { create(:sport) }

  describe "GET #index" do
    it "returns http success" do
      get :index, params: { sport_id: sport }
      expect(response).to have_http_status(:success)
    end
  end
end

# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe SoccerMatches::BasketsController, type: :controller do
  let(:season) { create(:season) }
  let(:match) { SoccerMatch.last }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }

  before do
    create(:soccer_match, division: division, baskets: [build(:basket)])
  end

  describe "GET #index" do
    it "returns http success" do
      get :index, params: { soccer_match_id: match }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #destroy" do
    let(:basket) { match.baskets.first }

    it "returns redirects" do
      delete :destroy, params: { soccer_match_id: match, id: basket }
      expect(response).to redirect_to match_baskets_path(match)
    end
  end
end

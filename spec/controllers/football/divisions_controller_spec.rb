# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

module Football
  RSpec.describe DivisionsController, type: :controller do
    let(:sport) { create(:soccer, basket_rules: [build(:basket_rule, name: "Rule 1")]) }
    let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
    let(:calendar) { create(:calendar, sport: sport) }
    let!(:division) { create(:division, calendar: calendar) }

    it "should_get_index" do
      get :index, params: { sport_id: sport }
      assert_response :success
      expect(assigns(:divisions)).not_to be_nil
    end

    it "should_show_division" do
      get :show, params: { id: division }
      assert_response :success
    end
  end
end

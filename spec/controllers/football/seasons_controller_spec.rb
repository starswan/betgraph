#
# $Id$
#
require "rails_helper"

module Football
  RSpec.describe SeasonsController, type: :controller do
    let(:sport) { create(:soccer) }
    let!(:calendar) { create(:calendar, sport: sport) }
    let(:division) { create(:division, calendar: calendar) }

    let!(:first_season) { create(:season, :first, calendar: calendar) }
    let!(:season) { create(:season, startdate: Time.zone.today, calendar: calendar) }
    let!(:final_season) { create(:season, :final, calendar: calendar) }
    let!(:sm_list) { create_list(:soccer_match, 1, division: division, kickofftime: season.startdate + 2.days + 15.hours) }

    describe "#show" do
      before do
        create(:soccer_match, division: division, kickofftime: final_season.startdate + 1.day)
        get :show, params: { sport_id: sport.id, season_id: season.id, threshold: 11 }
      end

      it "is successful" do
        expect(response).to be_successful
      end

      it "returns the matches that are interesting" do
        expect(assigns(:total)).to eq(0)
      end
    end

    it "gets index" do
      get :index, params: { sport_id: sport.id }
      assert_response :success
      expect(assigns(:seasons)).not_to be_nil
    end

    it "shows current football season" do
      Timecop.travel Date.new(2009, 9, 1) do
        get :show, params: { sport_id: sport.id, season_id: season.to_param, threshold: 7 }
        assert_response :success
      end
    end
  end
end

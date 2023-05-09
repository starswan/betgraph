# frozen_string_literal: true

require "rails_helper"

RSpec.describe TablesController, type: :controller do
  before do
    create(:season, :first)
    create(:season, :final)
    create(:soccer_match, kickofftime: date, division: division)
    create(:soccer_match, kickofftime: date, division: division, result: build(:result, homescore: 1, awayscore: 0))
    create(:soccer_match, kickofftime: date, division: division, result: build(:result, homescore: 0, awayscore: 1))
    create(:soccer_match, kickofftime: date, division: division, result: build(:result, homescore: 0, awayscore: 0))
  end

  let(:sport) { create(:soccer, calendars: build_list(:calendar, 1, seasons: build_list(:season, 2))) }
  let(:division) { create(:division, calendar: sport.calendars.first) }
  let(:season) { sport.calendars.first.seasons.last }
  let(:date) { season.startdate + 1.day }

  render_views

  describe "#index" do
    before do
      get :index, params: { division_id: division, season_id: season }
    end

    it "populates only the matches with results" do
      expect(assigns(:matches)).to match_array(SoccerMatch.last(3))
    end
  end

  describe "#show" do
    before do
      get :show, params: { division_id: division, season_id: season, id: date.to_s }
    end

    it "populates only the matches with results" do
      expect(assigns(:matches)).to match_array(SoccerMatch.last(3))
    end
  end
end

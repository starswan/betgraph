#
# $Id$
#
require "rails_helper"

RSpec.describe SoccerMatchesController, type: :controller do
  render_views

  let(:sport) { create(:soccer) }
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }
  let(:hometeam) { create(:team, sport: sport) }
  let(:awayteam) { create(:team, sport: sport) }
  let(:menu_path) { create(:menu_path, sport: sport) }

  before do
    create(:season, calendar: calendar)
  end

  it "gets index" do
    get :index, params: { division_id: division }
    assert_response :success
  end

  it "gets new" do
    get :new, params: { division_id: division }
    assert_response :success
  end

  context "with an existing match" do
    let!(:soccermatch) { create :soccer_match, live_priced: true, division: division, name: "#{hometeam.name} v #{awayteam.name}", kickofftime: Date.tomorrow }
    let(:mpt) { create(:market_price_time, time: soccermatch.kickofftime + 1.minute) }

    before do
      create(:betfair_market_type, name: "Correct Score", sport: sport)

      create :bet_market, name: "Correct Score", live: true, match: soccermatch, market_runners: [
        build(:market_runner, prices: build_list(:price, 1, market_price_time: mpt, created_at: mpt.time)),
      ]
    end

    it "can be replaced" do
      post :create, params: { division_id: division,
                              soccer_match: {
                                kickofftime: Time.zone.now,
                                name: "#{hometeam.name} v #{awayteam.name}",
                              } }, format: :json
      expect(response).to have_http_status(:created)
    end

    it "gets show" do
      get :show, params: { id: soccermatch }
      assert_response :success
    end

    it "gets show with offset" do
      get :show, params: { id: soccermatch, offset: 1 }
      assert_response :success
    end
  end

  # so the question that gets raised here is what should this controller do?
  # should it take the name of the match (A v B) and create an appropriate model?
  it "creates a 2 player match" do
    expect {
      post :create, params: { division_id: division,
                              soccer_match: {
                                kickofftime: Time.zone.now,
                                name: "#{hometeam.name} v #{awayteam.name}",
                              } }
      expect(response).to redirect_to(division_soccer_match_path(division, assigns(:match)))
    }.to change(SoccerMatch, :count).by(1)
    new_match = assigns(:match)
    expect(new_match.hometeam).to eq(hometeam)
    expect(new_match.awayteam).to eq(awayteam)
  end
end

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

  context "with an existing match" do
    let!(:soccermatch) do
      create :soccer_match, live_priced: false, division: division,
                            name: "#{hometeam.name} v #{awayteam.name}", kickofftime: Date.tomorrow
    end
    let(:mpt) { create(:market_price_time, time: soccermatch.kickofftime + 1.minute) }

    before do
      create(:betfair_market_type, name: "Correct Score", sport: sport)

      create :bet_market, name: "Correct Score", live: true, match: soccermatch, market_runners: [
        build(:market_runner, market_prices: build_list(:market_price, 1, market_price_time: mpt)),
      ]
    end

    describe "#destroy" do
      it "deletes match" do
        expect {
          delete :destroy, params: { id: soccermatch }, format: :json
        }.to change(SoccerMatch, :count).by(-1)
      end
    end

    describe "#update" do
      let(:ko_time) { Date.tomorrow + 1.day }
      let(:other_match) { create :soccer_match, live_priced: false, division: division, kickofftime: ko_time }

      it "errors" do
        patch :update, params: {
          id: soccermatch,
          soccer_match: {
            name: other_match.name,
          },
        }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "can be updated" do
        patch :update, params: {
          id: soccermatch,
          soccer_match: {
            live_priced: true,
          },
        }, format: :json
        expect(response).to have_http_status(:ok)
        expect(soccermatch.reload.live_priced).to eq(true)
      end

      it "can update kickoff time" do
        patch :update, params: {
          id: soccermatch,
          soccer_match: {
            kickofftime: ko_time,
          },
        }, format: :json
        expect(response).to have_http_status(:ok)
        expect(soccermatch.reload.kickofftime).to eq(ko_time)
      end
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
  # it "creates a 2 player match" do
  #   expect {
  #     post :create, params: { division_id: division,
  #                             soccer_match: {
  #                               kickofftime: Time.zone.now,
  #                               name: "#{hometeam.name} v #{awayteam.name}",
  #                             } }
  #     expect(response).to redirect_to(division_soccer_match_path(division, assigns(:match)))
  #   }.to change(SoccerMatch, :count).by(1)
  #   new_match = assigns(:match)
  #   expect(new_match.hometeam).to eq(hometeam)
  #   expect(new_match.awayteam).to eq(awayteam)
  # end
end

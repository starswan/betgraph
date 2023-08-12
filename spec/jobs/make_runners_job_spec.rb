# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe MakeRunnersJob, :vcr, :betfair, type: :job do
  let(:sport) do
    create(:soccer,
           betfair_market_types: build_list(:betfair_market_type, 1,
                                            betfair_runner_types: build_list(:betfair_runner_type, 1, :nilnil)))
  end
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }
  let(:match) { SoccerMatch.last }

  before do
    create(:season, calendar: calendar)
    create(:basket_rule,
           sport: sport,
           basket_rule_items: [
             build(:basket_rule_item, betfair_runner_type: sport.betfair_market_types.first.betfair_runner_types.first),
           ])
    create(:login)
    RefreshSportListJob.perform_now
    sport.competitions.find_by!(name: "English FA Cup").update!(active: true, division: division)
    #
    # BetMarket.all.update_all(active: true, live: true)
    # SoccerMatch.update_all(live_priced: true, kickofftime: Time.zone.now - 30.minutes)
    #
  end

  it "creates market runners" do
    expect {
      # make a few matches - but only really want one of them...
      MakeMatchesJob.perform_now(sport)
      # described_class.perform_later match.bet_markets.first
    }.to change(MarketRunner, :count).by(38)
    expect(BasketItem.count).to eq(2)
  end
end

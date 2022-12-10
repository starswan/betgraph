# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe MakeBasketItemsJob, type: :job do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }

  before do
    create(:basket_rule, sport: sport)
  end

  context "with rule item" do
    before do
      create(:soccer_match, division: division,
                            bet_markets: [
                              build(:bet_market,
                                    betfair_market_type: sport.betfair_market_types.first,
                                    name: "Correct Score",
                                    market_runners: [
                                      build(:market_runner),
                                      build(:market_runner),
                                    ]),
                            ])
      create(:basket_rule_item, basket_rule: sport.basket_rules.first, betfair_runner_type: BetfairMarketType.last.betfair_runner_types.first)
    end

    let(:runner) { match.bet_markets.first.market_runners.first }
    let(:match) { Match.last }

    it "creates items" do
      expect {
        described_class.perform_now runner
      }.to change(BasketItem, :count).by(1)
    end
  end
end

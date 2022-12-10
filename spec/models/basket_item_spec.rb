# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe BasketItem do
  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }

  let(:basket) do
    m = create(:soccer_match, division: division, bet_markets: [build(:bet_market, market_runners: [build(:market_runner)])])
    create(:basket, match: m)
  end
  let(:runner) { basket.match.bet_markets.first.market_runners.first }

  it "has a counter cache" do
    expect {
      basket.basket_items.create! weighting: 1,
                                  market_runner: runner
      basket.reload
    }.to change(basket, :basket_items_count).by(1)
  end
end

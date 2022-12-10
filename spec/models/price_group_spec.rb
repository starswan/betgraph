# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe PriceGroup, type: :model do
  before do
    create(:season, calendar: calendar)
  end

  let(:sport) { create(:sport, basket_rules: [build(:basket_rule, name: "Rule 1")]) }
  let(:market_type) { create(:betfair_market_type, name: "The Market Type", sport: sport) }
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }
  let(:hometeam) { create(:team) }
  let(:awayteam) { create(:team) }
  let(:menu_path) { create(:menu_path, sport: sport) }
  let(:soccermatch) do
    create(:soccer_match, live_priced: true, division: division,
                          name: "#{hometeam.name} v #{awayteam.name}")
  end

  let!(:bet_market) { create(:bet_market, match: soccermatch) }
  let!(:runner_one) { create(:market_runner, bet_market: bet_market) }
  let!(:runner_two) { create(:market_runner, bet_market: bet_market) }
  let!(:runner_three) { create(:market_runner, bet_market: bet_market) }

  let(:price_group) { described_class.new bet_market: bet_market, market_prices: prices }

  context "with no prices" do
    let(:prices) { [] }

    it "is invalid" do
      expect(price_group).not_to be_valid
    end
  end

  context "with 1 price" do
    let(:prices) { [build(:market_price, market_runner: runner_one, back1price: 1.02)] }

    it "is valid" do
      expect(price_group).to be_valid
    end
  end

  context "with 2 prices" do
    let(:prices) do
      [
        build(:market_price, market_runner: runner_one, back1price: 1.02),
        build(:market_price, market_runner: runner_two, back1price: 2),
      ]
    end

    it "is valid" do
      expect(price_group).to be_valid
    end
  end

  context "with 3 prices" do
    let(:prices) do
      [
        build(:market_price, market_runner: runner_one, back1price: 1.02),
        build(:market_price, market_runner: runner_two, back1price: 2),
        build(:market_price, market_runner: runner_three, back1price: 1.02),
      ]
    end

    it "is invalid" do
      expect(price_group).not_to be_valid
    end
  end
end

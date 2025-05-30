#
# $Id$
#
require "rails_helper"

RSpec.describe BetfairMarketType do
  before do
    create(:season, calendar: calendar)
  end

  let(:sport) { create(:soccer) }
  let(:calendar) { create(:calendar, sport: sport) }
  let(:division) { create(:division, calendar: calendar) }
  let(:soccermatch) do
    create(:soccer_match, live_priced: true, division: division,
                          name: "#{hometeam.name} v #{awayteam.name}")
  end

  let!(:twentyone) { create(:bet_market, match: soccermatch) }
  let(:menu_path) { create(:menu_path, sport: sport) }
  let(:awayteam) { create(:team) }
  let(:hometeam) { create(:team) }
  let!(:market_type) { create(:betfair_market_type, name: "The Market Type", valuer: "Winner", sport: sport, betfair_runner_types: [build(:betfair_runner_type)]) }

  context "over under goals" do
    let(:bmt) do
      build(:betfair_market_type, sport: build(:sport, name: "Soccer"), valuer: "OverUnderGoals")
    end

    it "values stuff" do
      expect(bmt.valuer_obj.expected_value(0.5, [{ homevalue: 1, backprice: 1.07, layprice: 1.08 }]))
          .to eq(OpenStruct.new(bid: 0.6554068525770983, ask: 0.7323678937132255))
    end

    it "values stuff with different target" do
      expect(bmt.valuer_obj.expected_value(1.5, [{ homevalue: 1, backprice: 1.07, layprice: 1.08 }]))
          .to eq(OpenStruct.new(bid: 1.6177047286013204, ask: 1.740513035897121))
    end
  end

  context "correct score" do
    let(:bmt) do
      build(:betfair_market_type, param1: 1, sport: build(:sport, name: "Soccer"), valuer: "CorrectScore")
    end

    it "values" do
      expect(bmt.expected_value(
               [{ homevalue: 0.0, awayvalue: 0.0, backprice: 19.0, layprice: 19.5 },
                { homevalue: 0.0, awayvalue: 1, backprice: 16.5, layprice: 19.0 },
                { homevalue: 0.0, awayvalue: 2, backprice: 26.0, layprice: 28.0 },
                { homevalue: 0.0, awayvalue: 3, backprice: 50.0, layprice: 70.0 },
                { homevalue: 1.0, awayvalue: 0.0, backprice: 12.5, layprice: 13.5 },
                { homevalue: 1.0, awayvalue: 1, backprice: 8.4, layprice: 8.8 },
                { homevalue: 1.0, awayvalue: 2, backprice: 13.5, layprice: 14.5 },
                { homevalue: 1.0, awayvalue: 3, backprice: 32.0, layprice: 36.0 },
                { homevalue: 2.0, awayvalue: 0.0, backprice: 14.0, layprice: 15.0 },
                { homevalue: 2.0, awayvalue: 1, backprice: 10.5, layprice: 11.0 },
                { homevalue: 2.0, awayvalue: 2, backprice: 13.0, layprice: 14.0 },
                { homevalue: 2.0, awayvalue: 3, backprice: 34.0, layprice: 38.0 },
                { homevalue: 3.0, awayvalue: 0.0, backprice: 25.0, layprice: 36.0 },
                { homevalue: 3.0, awayvalue: 1, backprice: 18.0, layprice: 19.0 },
                { homevalue: 3.0, awayvalue: 2, backprice: 26.0, layprice: 29.0 },
                { homevalue: 3.0, awayvalue: 3, backprice: 60.0, layprice: 70.0 }],
               # {:homevalue=>-1.0, :awayvalue=>0.0, :backprice=>10.5, :layprice=>11.5},
               # {:homevalue=>0.0, :awayvalue=>-1.0, :backprice=>23.0, :layprice=>25.0},
               # {:homevalue=>-1.0, :awayvalue=>-1.0, :backprice=>310.0, :layprice=>1000.0}
             )).to eq(OpenStruct.new(bid: nil, ask: nil))
    end
  end

  it "destroys dependent runner types" do
    expect { market_type.destroy }.to change(BetfairRunnerType, :count).by(-1)
  end

  it "destroys dependent_markets" do
    expect {
      twentyone.destroy
    }.to change(BetMarket, :count).by(-1)
  end

  it "has an expected value" do
    expect(market_type.expected_value(1)).to eq(OpenStruct.new(bid: nil, ask: nil))
  end
end

#
# $Id$
#
require "rails_helper"
require "lay_price_set"
require "back_price_set"
require "runner_set"

RSpec.describe RunnerSet do
  let(:rs) { described_class.new }

  context "with 50/20/20/10" do
    before do
      p = [[11.0, 1], [6.0, 2], [6.0, 2], [2.0, 10]]
      p.map { |h| BackPriceSet.new h }.each_with_index { |v, i| rs.addPriceSet(i, v) }
    end

    describe "#price_weights" do
      it "returns correct weights" do
        expect(rs.price_weights).to eq([6, 11, 11, 33])
      end
    end

    describe "#over_round" do
      it "returns answer" do
        expect(rs.over_round).to be_within(1e-5).of(0.924242)
      end
    end
  end

  # This appears to show a real-world risk-free profit of £27.97
  it "copes with real-world data" do
    p = [[3.25, 16.41], [25.0, 77.56], [9.6, 78.2], [19.0, 37.52], [2.6, 208.84]]
    p.map { |h| BackPriceSet.new h }.each_with_index { |v, i| rs.addPriceSet(i, v) }
    expect(rs.over_round).to be_within(1e-3).of(0.889)
    expect(rs.max_prices).to match_array [{ amount: 77.56, price: 3.25, weight: 77.56, runner: 1 },
                                          { amount: 16.41, price: 25.0, weight: 10.08, runner: 0 },
                                          { amount: 78.2, price: 9.6, weight: 26.26, runner: 2 },
                                          { amount: 37.52, price: 19.0, weight: 13.27, runner: 3 },
                                          { amount: 208.84, price: 2.6, weight: 96.95, runner: 4 }]
  end

  it "lay price set overround" do
    lps = LayPriceSet.new [1.5, 2]
    expect(lps.probability).to be_within(1e-5).of(1.0 / 3)
  end

  it "back price set overround" do
    rs.addPriceSet 1, BackPriceSet.new([4.0, 2])
    expect(rs.over_round).to eq(0.25)
    expect(rs.max_prices).to eq([{ amount: 2, price: 4.0, weight: 2.0, runner: 1 }])
  end

  it "runner set overround" do
    lrs = described_class.new
    lrs.addPriceSet 1, LayPriceSet.new([1.5, 2])
    lrs.addPriceSet 2, LayPriceSet.new([1.5, 2])

    expect(lrs.over_round).to be_within(1e-5).of(2.0 / 3)
  end
end

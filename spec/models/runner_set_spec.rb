# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"
require "lay_price_set"
require "back_price_set"
require "runner_set"

RSpec.describe RunnerSet do
  it "lay price set overround" do
    lps = LayPriceSet.new
    lps.addPrice 1.5, 2

    expect(lps.overRound).to be_within(1e-5).of(1.0 / 3)
  end

  it "back price set overround" do
    bps = BackPriceSet.new
    bps.addPrice 4, 2
    expect(bps.overRound).to eq(0.25)
  end

  it "runner set overround" do
    lrs = described_class.new

    lps1 = LayPriceSet.new
    lps1.addPrice 1.5, 2
    lrs.addPriceSet 1, lps1

    lps2 = LayPriceSet.new
    lps2.addPrice 1.5, 2
    lrs.addPriceSet 2, lps2

    expect(lrs.overRound).to be_within(1e-5).of(2.0 / 3)
  end
end
